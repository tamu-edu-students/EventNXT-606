import IndexController from "controllers/index_controller";

export default class BoxofficeController extends IndexController {
    static values = { eventid: Number};
  
     /*global Rails*/
   query(event) {
  let eventId = event.currentTarget.dataset.boxofficeEventidValue;
  let url = event.currentTarget.dataset.boxofficeUrlValue;

    Rails.ajax({
    type: 'GET',
    url: url,
    data: {
      event_id: eventId
    },
    success: (data) => {
      this.update(data);
    },
    error: (err) => {
      console.log(err);
    }
  });
}


    postProcess() {
      this.updateHeaders();
    }
    /*global fetch*/
    /*global localStorage*/
    loadHeader() {
      let row = document.querySelector("input#header-line").value
      fetch(`/api/v1/events/${this.eventidValue}/headers/${row}`, {
        headers: {
          "Authorization": "Bearer " + localStorage.getItem("access_token"),
          method: "GET",
        }
      }).then(response => response.json())
      .then(templates => {
        this.createDropdown("boxoffice-firstName", "boxoffice-container-firstName",
        templates.row, 0);
        this.createDropdown("boxoffice-lastName", "boxoffice-container-lastName",
        templates.row, 0);
        this.createDropdown("boxoffice-email", "boxoffice-container-email",
        templates.row, 0);
        this.createDropdown("boxoffice-seatLevel", "boxoffice-container-seatLevel",
        templates.row, 0);
        this.createDropdown("boxoffice-seats", "boxoffice-container-seats",
        templates.row, 0);
      });
  }
  createDropdown(element, divElement, rows, value) {
    let i = 0;
    var select = document.getElementById(element);
    var div =  document.getElementById(divElement);
    select.innerHTML = '';
    for (const val of rows) {
      var option = document.createElement("option");
      option.value = i;
      option.text = val;
      select.appendChild(option);
      i++;
    }
    select.value = value;
    div.appendChild(select);
  }

  loadData(e) {
    var header = document.querySelector("input#header-line").value
  
    var firstName = this.getSelectedID("boxoffice-firstName");
    var lastName = this.getSelectedID("boxoffice-lastName");
    var email = this.getSelectedID("boxoffice-email");
    var seatLevel = this.getSelectedID("boxoffice-seatLevel");
    var seats = this.getSelectedID("boxoffice-seats");
    
    fetch(`/api/v1/events/${this.eventidValue}/dataload/${header}/${firstName}/${lastName}/${email}/${seatLevel}/${seats}`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
      },
      method: "GET",
    }).then(response => {super.query(); super.getCount();
    this.dispatch('dataLoaded')});
  }

  getSelectedID(element){
    var select = document.getElementById(element);
    var options = select.options;
    return options.selectedIndex;
  }

  updateValue(elementId, value){
    document.getElementById(elementId).value = value;
  }

  updateDropDown(){
    fetch(`/api/v1/events/${this.eventidValue}/boxoffice_headers`)
    .then(response => response.json())
    .then(data => {
      var values = data[0]
      this.updateValue('boxoffice-firstName', values.first_name);
      this.updateValue('boxoffice-lastName', values.last_name);
      this.updateValue('boxoffice-email', values.email);
      this.updateValue('boxoffice-seatLevel', values.seat_section);
      this.updateValue('boxoffice-seats', values.tickets);
    });
  }

  loadStoredHeader(values) {
    let row = document.querySelector("input#header-line").value
    fetch(`/api/v1/events/${this.eventidValue}/headers/${row}`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
        method: "GET",
      }
    }).then(response => response.json())
    .then(templates => {
      this.createDropdown("boxoffice-firstName", "boxoffice-container-firstName",
      templates.row, values.first_name);
      this.createDropdown("boxoffice-lastName", "boxoffice-container-lastName",
      templates.row, values.last_name);
      this.createDropdown("boxoffice-email", "boxoffice-container-email",
      templates.row, values.email);
      this.createDropdown("boxoffice-seatLevel", "boxoffice-container-seatLevel",
      templates.row, values.seat_section);
      this.createDropdown("boxoffice-seats", "boxoffice-container-seats",
      templates.row, values.tickets);
    });
}
  updateHeaders() {
    fetch(`/api/v1/events/${this.eventidValue}/boxoffice_headers`)
      .then(response => response.json())
      .then(data => {
        var values = data[0]
        //this.updateValue('header-line', values.header_row);
        document.getElementById('header-line').value = values.header_row;
        this.loadStoredHeader(values);
        this.dispatch('dataLoaded')
      });
};
    
}
