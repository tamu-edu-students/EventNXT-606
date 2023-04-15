#include <iostream>
#include <memory>
#include <string>
#include <map>
#include <vector>
#include <mutex>
#include <thread>
#include <grpcpp/grpcpp.h>
#include "snsCoordinator.grpc.pb.h"
#include <glog/logging.h>
#include <google/protobuf/util/time_util.h>
#include <chrono>
#include <iomanip>
#include <ctime>

#define log(severity, msg) \
    LOG(severity) << msg;  \
    google::FlushLogFiles(google::severity);

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::ServerReader;
using grpc::ServerReaderWriter;
using grpc::ServerWriter;
using grpc::Status;
using snsCoordinator::ClusterId;
using snsCoordinator::FollowSyncs;
using snsCoordinator::Heartbeat;
using snsCoordinator::SNSCoordinator;
using snsCoordinator::User;
using snsCoordinator::Users;

// enumerations for readability
enum class ServerStatus
{
    ACTIVE,
    INACTIVE
};
enum class ServerType
{
    MASTER,
    SLAVE,
    SYNCHRONIZER
};

// used to represent a server (master or slave will be the same just identified by server type)
struct Server_obj
{
    int server_id;
    std::string ip_address;
    std::string port_number;
    ServerStatus status;
    ServerType type;
};

// routing information which stores info for all servers
struct RoutingTable
{
    std::map<int, Server_obj> masterServers;
    std::map<int, Server_obj> slaveServers;
    std::map<int, Server_obj> synchronizerServers;
    std::mutex table_mutex;
};

// struct to hold heartbeat info
struct HeartbeatInfo
{
    ServerType server_type;
    std::string server_ip;
    std::string server_port;
    google::protobuf::Timestamp last_heartbeat_timestamp;
    bool is_active;
};

// global variables for routing table and heartbeat info
RoutingTable routingTable;
std::map<int, std::pair<HeartbeatInfo, HeartbeatInfo>> heartbeat_info_map;
std::mutex heartbeat_info_map_mutex;

void updateServerStatus(RoutingTable &table, int server_id, ServerType type, ServerStatus new_status)
{
    std::unique_lock<std::mutex> lock(table.table_mutex);

    if (type == ServerType::MASTER)
    {
        table.masterServers[server_id].status = new_status;
    }
    else if (type == ServerType::SLAVE)
    {
        table.slaveServers[server_id].status = new_status;
    }
    else if (type == ServerType::SYNCHRONIZER)
    {
        table.synchronizerServers[server_id].status = new_status;
    }

    lock.unlock();
}

Server_obj pair_servers(int serverId, ServerType serverType, RoutingTable &routingTable)
{
    Server_obj paired_server;
    paired_server.server_id = -1;

    if (serverType == ServerType::MASTER)
    {
        auto slave_itr = routingTable.slaveServers.find(serverId);
        if (slave_itr != routingTable.slaveServers.end() && slave_itr->second.status == ServerStatus::INACTIVE)
        {
            paired_server = slave_itr->second;
        }
    }
    else if (serverType == ServerType::SLAVE)
    {
        auto master_itr = routingTable.masterServers.find(serverId);
        if (master_itr != routingTable.masterServers.end() && master_itr->second.status == ServerStatus::ACTIVE)
        {
            paired_server = master_itr->second;
        }
    }

    return paired_server;
}

Server_obj createServerFromRequest(const snsCoordinator::Server *server_info)
{
    Server_obj server;
    server.server_id = server_info->server_id();
    server.ip_address = server_info->server_ip();
    server.port_number = server_info->port_num();
    server.type = (ServerType)server_info->server_type();
    server.status = (ServerStatus)server_info->server_status();
    return server;
}

bool registerServerToRoutingTable(Server_obj &server, RoutingTable &routingTable)
{
    std::unique_lock<std::mutex> lock(routingTable.table_mutex);
    if (server.type == ServerType::MASTER)
    {
        server.status = ServerStatus::ACTIVE;
        routingTable.masterServers[server.server_id] = server;
    }
    else if (server.type == ServerType::SLAVE)
    {
        server.status = ServerStatus::INACTIVE;
        routingTable.slaveServers[server.server_id] = server;
    }
    else if (server.type == ServerType::SYNCHRONIZER)
    {
        server.status = ServerStatus::ACTIVE;
        routingTable.synchronizerServers[server.server_id] = server;
    }
    else
    {
        lock.unlock();
        return false;
    }
    lock.unlock();
    return true;
}

void setResponseForPairedServer(snsCoordinator::Server *response, const Server_obj &paired_server, snsCoordinator::ServerType server_type)
{
    response->set_server_id(paired_server.server_id);
    response->set_server_ip(paired_server.ip_address);
    response->set_port_num(paired_server.port_number);
    response->set_server_type(server_type);
    response->set_server_status(snsCoordinator::Server_Server_Status::Server_Server_Status_PAIRED);
}

std::chrono::system_clock::time_point convert_to_time_point(const google::protobuf::Timestamp &timestamp)
{
    return std::chrono::system_clock::time_point(std::chrono::seconds(timestamp.seconds()) + std::chrono::nanoseconds(timestamp.nanos()));
}

void monitor_heartbeats(std::map<int, std::pair<HeartbeatInfo, HeartbeatInfo>> &heartbeat_info_map, std::mutex &heartbeat_info_map_mutex)
{
    while (true)
    {
        std::unique_lock<std::mutex> lock(heartbeat_info_map_mutex);
        auto now = std::chrono::system_clock::now();

        for (auto &entry : heartbeat_info_map)
        {
            // Check the master server's heartbeat
            HeartbeatInfo &master_info = entry.second.first;
            auto last_master_heartbeat_timestamp = convert_to_time_point(master_info.last_heartbeat_timestamp);

            // Check if the master server has missed two heartbeats
            if (std::chrono::duration_cast<std::chrono::seconds>(now - last_master_heartbeat_timestamp).count() > 20)
            {
                // Mark the master server as inactive
                master_info.is_active = false;

                // Promote the slave server to master
                // ...
            }
            std::chrono::system_clock::time_point tp = std::chrono::system_clock::from_time_t(last_master_heartbeat_timestamp.time_since_epoch().count());
            std::time_t tt = std::chrono::system_clock::to_time_t(tp);
            std::tm *t = std::localtime(&tt);

            // std::cout << "Master Server ID: " << entry.first << ", Last Heartbeat Timestamp: " << std::put_time(t, "%Y-%m-%d %H:%M:%S") << ", Is Active: " << master_info.is_active << std::endl;
            std::cout << "Master Server ID: " << entry.first << ", Raw Last Heartbeat Timestamp: " << master_info.last_heartbeat_timestamp << std::endl;

            // Optional: check the slave server's heartbeat
            /*
            HeartbeatInfo &slave_info = entry.second.second;
            auto last_slave_heartbeat_timestamp = convert_to_time_point(slave_info.last_heartbeat_timestamp);
            if (std::chrono::duration_cast<std::chrono::seconds>(now - last_slave_heartbeat_timestamp).count() > 20)
            {
                // Mark the slave server as inactive
                slave_info.is_active = false;
            }
            std::cout << "Slave Server ID: " << entry.first << ", Last Heartbeat Timestamp: " << last_slave_heartbeat_timestamp.time_since_epoch().count() << ", Is Active: " << slave_info.is_active << std::endl;
            */
        }

        lock.unlock();

        // Sleep for 10 seconds before checking heartbeats again
        std::this_thread::sleep_for(std::chrono::seconds(10));
    }
}

class SNSCoordinatorImpl final : public SNSCoordinator::Service
{
    Status HandleHeartBeats(grpc::ServerContext *context, grpc::ServerReaderWriter<Heartbeat, Heartbeat> *stream) override
    {
        Heartbeat incoming_heartbeat;
        while (stream->Read(&incoming_heartbeat))
        {
            // Update the heartbeat information in the map
            int cluster_id = incoming_heartbeat.server_id();
            ServerType server_type = (ServerType)incoming_heartbeat.server_type();

            HeartbeatInfo &heartbeat_info = (server_type == ServerType::MASTER)
                                                ? heartbeat_info_map[cluster_id].first
                                                : heartbeat_info_map[cluster_id].second;

            heartbeat_info.server_type = server_type;
            heartbeat_info.server_ip = incoming_heartbeat.server_ip();
            heartbeat_info.server_port = incoming_heartbeat.server_port();
            heartbeat_info.last_heartbeat_timestamp = incoming_heartbeat.timestamp();
            heartbeat_info.is_active = true; // Server is active as it just sent a heartbeat

            // Prepare the response
            Heartbeat response;
            response.set_server_id(cluster_id);
            response.set_server_type((snsCoordinator::ServerType)server_type);
            response.set_server_ip(heartbeat_info.server_ip);
            response.set_server_port(heartbeat_info.server_port);
            *response.mutable_timestamp() = google::protobuf::util::TimeUtil::GetCurrentTime();

            // TODO: Set additional response fields if needed (e.g., new server role)

            // Write the response back to the stream
            stream->Write(response);
        }

        return Status::OK;
    }

    Status GetFollowSyncsForUsers(grpc::ServerContext *context, const Users *users, FollowSyncs *follow_syncs) override
    {
        // Implement the logic to get FollowSyncs for users
        return Status::OK;
    }

    Status GetServer(grpc::ServerContext *context, const User *user, snsCoordinator::Server *server) override
    {
        // Implement the logic to get a server for a user
        return Status::OK;
    }

    Status GetSlave(grpc::ServerContext *context, const ClusterId *cluster_id, snsCoordinator::Server *server) override
    {
        // Implement the logic to get a slave server for a given cluster
        return Status::OK;
    }
    Status RegisterServer(grpc::ServerContext *context, const snsCoordinator::Server *server_info, snsCoordinator::Server *response) override
    {
        Server_obj server = createServerFromRequest(server_info);

        if (!registerServerToRoutingTable(server, routingTable))
        {
            log(ERROR, "Invalid server type");
            return Status::CANCELLED;
        }

        // If the server is a synchronizer, we don't need to pair it.
        if (server.type == ServerType::SYNCHRONIZER)
        {
            response->set_server_status(snsCoordinator::Server_Server_Status::Server_Server_Status_NOT_PAIRED);
            log(INFO, "Synchronizer server registered with id: " + std::to_string(server.server_id));
            return Status::OK;
        }

        // After setting up with coordinator, attempt to pair with another server if its a master or slave
        Server_obj paired_server = pair_servers(server.server_id, server.type, routingTable);
        snsCoordinator::ServerType server_type;

        if (paired_server.server_id != -1)
        {
            snsCoordinator::ServerType server_type = server.type == ServerType::MASTER ? snsCoordinator::ServerType::SLAVE : snsCoordinator::ServerType::MASTER;
            setResponseForPairedServer(response, paired_server, server_type);
            log(INFO, "Paired with server: " + std::to_string(paired_server.server_id));
        }
        else
        {
            response->set_server_status(snsCoordinator::Server_Server_Status::Server_Server_Status_NOT_PAIRED);
            log(INFO, "No server to pair with");
        }
        return Status::OK;
    }
};

void RunServer(std::string port_no)
{
    // build server and then start the thread to monitor heartbeats
    std::string server_address = "0.0.0.0:" + port_no;
    SNSCoordinatorImpl service;

    ServerBuilder builder;
    builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
    builder.RegisterService(&service);
    std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
    std::cout << "Coordinator Server listening on " << server_address << std::endl;
    log(INFO, "Coordinator Server listening on " + server_address);
    
    std::thread monitor_thread(monitor_heartbeats, std::ref(heartbeat_info_map), std::ref(heartbeat_info_map_mutex));

    server->Wait();
    monitor_thread.join();
}

int main(int argc, char **argv)
{
    std::string port = "3010";

    int opt = 0;
    while ((opt = getopt(argc, argv, "p:")) != -1)
    {
        switch (opt)
        {
        case 'p':
            port = optarg;
            break;
        default:
            std::cerr << "Invalid Command Line Argument\n";
        }
    }

    std::string log_file_name = std::string("server-") + port;
    google::InitGoogleLogging(log_file_name.c_str());
    log(INFO, "Logging Initialized. Server starting...");
    RunServer(port);

    return 0;
}