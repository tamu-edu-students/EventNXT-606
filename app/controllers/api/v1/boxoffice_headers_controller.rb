class Api::V1::BoxofficeHeadersController < Api::V1::ApiController
    def index
        headers = BoxofficeHeaders.where(event_id: params[:event_id])
        render json: headers.map {|headers|  headers.as_json};
      end
    def header_names
    header_names = BoxofficeHeaders.where(event_id: params[:event_id]).pluck(:name)
    render json: header_names
  end
end
