import IndexController from "controllers/index_controller";

export default class BookController extends IndexController {
  static targets = [ 'form', 'submit' ]
  static values = { eventid: Number, guestid: Number }

  disableSubmit() {
    console.log("refer called")
    this.submitTarget.textContent = 'Submitted'
    this.submitTarget.disabled = true
  }

}
