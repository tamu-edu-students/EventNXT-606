import IndexController from "controllers/index_controller";

export default class PurchaseController extends IndexController {
  static targets = [ 'form', 'submit', 'sum' ];
  static values = { eventid: Number, guestid: Number, sumofall: Number };

  preProcess() {
    this.showExpiry()
    this.handleSum()
    this.submit = this.formTarget.firstElementChild.cloneNode(true)
  }

  postProcess() {
    this.formTarget.append(this.submit)
    //this.handleSeatCategory()
    //this.handleMaxCommittment()
  }

  showExpiry() {
    let guestData = new FormData();
    guestData.append('guest_id', this.guestidValue)
    fetch(`/api/v1/guest/get_expired`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
      },
      method: "POST",
      body: guestData
    }).then(response => response.json())
    .then(data => {
      console.log(data)
      if(data){
      let bookDom = document.getElementById("book")
      bookDom.innerHTML = "<br><br><h3>The RSVP link has expired. Please go to the FashioNXT events page to book the tickets.</h3>"
      }
    })
  }

  handleSum(){
    fetch(`/api/v1/events/${this.eventidValue}/guests/${this.guestidValue}/sum_all`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token")
      }
    }).then(response => response.json())
      .then(data => {this.sumofall = data;this.setsum()})
    }

  setsum()
  {
    let elem = this.sumTarget.querySelector(`[data-nxt-sum]`);
    elem.innerHTML = this.sumofall;
  }

  handleMaxCommittment()
  {
      let inputCommitted = this.sumTarget.querySelector('input[data-nxt-guestcommitted]')
      let maxAllotted = this.sumofall
      inputCommitted.setAttribute('max', maxAllotted)
  }

  updateGuestCommitted() {
    let inputCommittedValue = this.sumTarget.querySelector('input[data-nxt-guestcommitted]').value
    fetch(`/api/v1/events/${this.eventidValue}/guests/${this.guestidValue}/${inputCommittedValue}/updaterefcommitted`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
      },
      method: "POST",
    }).then(response => 'ok')
      //.then(data => {this.sendmail()})
    this.sumTarget.reset();
  }
  
  
  sendmail()
  {
    fetch(`/api/v1/events/${this.eventidValue}/guests/${this.guestidValue}/countmail`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
      }
    }).then(response => response.json())
  }


  sendTickets(e) {
    e.preventDefault() 
    this.handleMaxCommittment()
    let error = document.getElementById("error");
    let inputCommittedValue = this.sumTarget.querySelector('input[data-nxt-guestcommitted]').value
    let inputCommitted = this.sumTarget.querySelector('input[data-nxt-guestcommitted]')
    if(inputCommittedValue <= this.sumofall)
    {
      error.textContent = ""
      this.disableSubmit()
      this.updateGuestCommitted()
    }
    else{
      this.sumTarget.querySelector('input[data-nxt-guestcommitted]').value = 0
      error.textContent = "Please enter an input less than max"
      error.style.color = "red"
    }
  }

  disableSubmit() {
    this.submitTarget.textContent = 'Submitted'
    this.submitTarget.disabled = true
  }

}
