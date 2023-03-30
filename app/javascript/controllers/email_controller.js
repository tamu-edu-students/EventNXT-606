import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'email', 'template', 'name', 'select', 'subject', 'body', 'from' ];
  static values = { eventid: Number, mailfrom: String};

  connect() {
    this.queryTemplates();
  }

  queryTemplates() {
    this.setmail();
    fetch(`/api/v1/events/${this.eventidValue}/templates`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
        method: "GET",
      }
    }).then(response => response.json())
      .then(templates => {
        const generic = this.selectTarget.firstElementChild
        this.selectTarget.innerHTML = '';
        this.selectTarget.appendChild(generic);
        for (const template of templates) {
          this.selectTarget.insertAdjacentHTML('beforeend', 
            this.createTemplateOption(template['id'], template['name']));
        }
      });
  }
  
  
  setmail()
  {

    fetch(`/api/v1/events/${this.eventidValue}/guests/mail`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
        method: "GET",
      }
    }).then(response => response.json())
      .then(data => {this.mailfrom = data.email;this.sendfrom();})
      .then(data => console.log(this.mailfrom));

  }

  sendfrom()
  {
    let elem = this.fromTarget.querySelector(`input[data-nxt-frommail]`);
    elem.setAttribute('value', this.mailfrom)
  }


  createTemplateOption(id, name) {
    return `<option value='${id}'>${name}</option>`;
  }

  loadTemplate() {
    if (!this.selectTarget.value || this.selectTarget.value === '') {
      if (this.hasEmailTarget)
        this.emailTarget.reset();
      if (this.hasTemplateTarget)
        this.templateTarget.reset();
      return;
    }
    fetch(`/api/v1/events/${this.eventidValue}/templates/${this.selectTarget.value}`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
        method: "GET",
      }
    }).then(response => response.json())
      .then(data => {
        if (this.hasNameTarget) {
          this.nameTarget.value = data['name'];
        }
        this.subjectTarget.value = data['subject'];
        this.bodyTarget.value = data['body'];
      })
  }

  deleteTemplate(e) {
    fetch(`/api/v1/events/${this.eventidValue}/templates/${this.selectTarget.value}`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
      },
      method: "DELETE"
    }).then(response => this.queryTemplates())
    this.templateTarget.reset();
  }

  sendEmail(e) {
    fetch(`/api/v1/email`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
      },
      method: "POST",
      body: new FormData(this.emailTarget)
    }).then(response => this.dispatch('emailed'))
    this.emailTarget.reset();
  }

  sendBulkEmail(e) {
    fetch(`/api/v1/email/bulk`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
      },
      method: "POST",
      body: new FormData(this.emailTarget)
    }).then(response => this.dispatch('emailed'))
    this.emailTarget.reset();
  }
  
    sendBulkReferralEmail(e) {
    fetch(`/api/v1/email/bulkReferral`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
      },
      method: "POST",
      body: new FormData(this.emailTarget)
    }).then(response => this.dispatch('emailed'))
    this.emailTarget.reset();
  }

  sendTemplate(e) {
    let method;
    let resource;
    if (!this.selectTarget.value || this.selectTarget.value === '') {
      method = 'POST'
      resource = ''
    } else {
      method = 'PATCH'
      resource = `/${this.selectTarget.value}`
    }
    fetch(`/api/v1/events/${this.eventidValue}/templates${resource}`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
      },
      method: method,
      body: new FormData(this.templateTarget)
    }).then(response => this.queryTemplates())
    this.templateTarget.reset();
  }
}
