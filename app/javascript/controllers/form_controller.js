import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'bad', 'error']
  static values = { redirect: String }

  submitSaveLocal(e) {
    e.preventDefault();
    this.submit(function(res) {
      for (const [key, value] of Object.entries(res))
        localStorage.setItem(key, value);
    });
  }

  submitForm(e) {
    e.preventDefault();
    this.submit();
  }

  submit(callback = () => {}) {
    var dat = new FormData(this.element);
    var req = new XMLHttpRequest();
    
    req.open(this.element.getAttribute('method'), this.element.getAttribute('action'))
    req.controller = this;
    req.onload = function() {
      if(this.controller.errorTarget) {
        this.controller.errorTarget.textContent = ""
      }  
      if (this.status >= 200 && this.status < 300) {
        var res = this.response ? JSON.parse(this.response) : this.response;
        callback(res, this.controller);
  
        if (this.controller.hasRedirectValue)
          window.location.href = this.controller.redirectValue;
      }
      else if (this.controller.hasBadTarget) {
        for (const t of this.controller.badTargets)
          t.classList.add('is-invalid');
      }
      if(this.status >= 400 && this.status < 500){
        var res = this.response ? JSON.parse(this.response) : this.response;
        if(this.controller.errorTarget && res["error_description"]) {
          this.controller.errorTarget.textContent = res["error_description"]
        }
      }
      
    }
    req.send(dat);
  }

}