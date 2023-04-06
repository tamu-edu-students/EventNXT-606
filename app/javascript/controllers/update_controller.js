import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'template', 'dom', 'update' ];
  static values = { url: String };

  sendFromForm(e) {
    e.preventDefault();
    let form = e.currentTarget;
    if (!form.checkValidity())
      return;

    let payload = new FormData(form);
    payload.delete('id')
    payload.delete('access_token');
    payload.delete('authenticity_token');

    let id = form.querySelector('input[data-nxt-id]');
    if (!id || id.value === '')
      this.create(payload);
    else
      this.update(payload, id.value);
    let fd = new FormData(this.formTarget)

    fetch(`/api/v1/events/${this.eventidValue}/guests/${this.guestidValue}/send`, {
      method: 'GET',
      body: fd
    }).then(response => {
      if (response.ok) {
        this.disableSubmit()
      }
    })
  }
  
  sendCountForm(e) {
    e.preventDefault();
    let form = e.currentTarget;
    if (!form.checkValidity())
      return;

    let payload = new FormData(form);
    payload.delete('id')
    payload.delete('access_token');
    payload.delete('authenticity_token');

    let id = form.querySelector('input[data-nxt-id]');
    if (!id || id.value === '')
      this.create(payload);
    else
      this.update(payload, id.value);
    let fd = new FormData(this.formTarget)
    fetch(`/api/v1/events/${this.eventidValue}/guests/${this.guestidValue}/ref_count`, {
      method: 'GET',
      body: fd
    }).then(response => {
      if (response.ok) {
        this.disableSubmit()
      }
    })
  }

  updateBatchFromCheckbox({ params: { payload } }) {
    if (this.updateTargets.length > 0) {
      this.updateTargets.forEach( elem => {
        let checkbox = elem.querySelector('input[type="checkbox"][data-nxt-id]');
        if (!checkbox.checked) 
          return;
        fetch(`${this.urlValue}/${checkbox.value}`, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('access_token')}`,
            'content-type': 'application/json'
          },
          method: 'PATCH',
          body: JSON.stringify(payload)
        }).then(response => {this.dispatch('updated')})
        //   .then(data => {
        //   elem.replaceWith(this.fillTemplate(data, elem));
        // })
        checkbox.checked = false;
      })
    }
  }

  create(payload) {
    fetch(`${this.urlValue}`, {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('access_token')}`,
      },
      method: 'POST',
      body: payload
    }).then(response => response.json())
      .then(data => this.dispatch('created', {detail: data}))
  }

  update(payload, id) {
    fetch(`${this.urlValue}/${id}`, {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('access_token')}`,
      },
      method: 'PATCH',
      body: payload
    }).then(response => response.json())
      .then(data => this.dispatch('updated', {detail: data}))

  }
}
