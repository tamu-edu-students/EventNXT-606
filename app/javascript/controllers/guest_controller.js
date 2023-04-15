import IndexController from "controllers/index_controller";

export default class GuestController extends IndexController {
  static targets = [ 'add', 'seat', 'tooltip', 'expiry' ];
  static values = { seaturl: String };

  query() {
    super.query();
  }

  preProcess() {
    this.headers = this.domTarget.firstElementChild.cloneNode(true)
    // this.add = this.domTarget.lastElementChild.cloneNode(true)
  }

  postProcess() {
    // this.setupForms()
    this.genNoGuestMessage()
    this.domTarget.prepend(this.headers);
    // this.domTarget.append(this.add);

    this.genTooltips();
    this.handleBookStatus();
    this.handleGuestCommitted();
    this.handleAddedBy();
    this.updateSeats();
  }

  setupForms() {
    let trs = this.domTarget.querySelectorAll('tr')
    for (const tr of trs) {
      let form = tr.querySelector('form[data-nxt-id]')
      form.id = `form-${form.getAttribute('data-nxt-id')}`
      let formid = form.id
      
      let inputs = tr.querySelectorAll('[name]')
      for (const input of inputs)
        input.setAttribute('form', formid)
    }
  }

  setRSVPExpiry(e) {
    fetch(`/api/v1/guest/set_expiry`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
      },
      method: "POST",
      body: new FormData(this.expiryTarget)
    }).then(response => this.dispatch('complete_set_expiry'))
    this.expiryTarget.reset();
  }

  genNoGuestMessage() {
    if (this.domTarget.childElementCount != 0)
      return;

    let rowDiv = document.createElement('div')
    let colDiv = document.createElement('div')
    let msg = document.createTextNode('No guests.')
    rowDiv.classList.add('row')
    colDiv.classList.add('col-lg')
    colDiv.classList.add('text-center')
    colDiv.append(msg)
    rowDiv.append(colDiv)
    this.domTarget.append(rowDiv)
  }

  genTooltips() {
    for (const dom of this.tooltipTargets) {
      if (dom.childNodes.length === 0) {
        dom.remove();
        continue;
      }

      //let tooltip = new bootstrap.Tooltip(dom, {boundary: document.body});
      dom.setAttribute('data-bs-toggle', 'tooltip');
      dom.setAttribute('data-bs-placement', 'top');
      dom.title = dom.textContent;
      dom.textContent = '';
    }
  }

  handleBookStatus() {
    for (const dom of this.element.querySelectorAll('i[data-nxt-booked]')) {
      if (dom.textContent === 'false')
        dom.remove();
      else {
        dom.textContent = '';
        dom.title = 'booked';
      }
    }
  }
  
  handleGuestCommitted() {
    let iter = 0
    for (const dom of this.element.querySelectorAll('p[data-nxt-guestcommitted]')) {
      fetch(`/api/v1/guests/${dom.textContent}`)
        .then(response => response.json())
        .then(data => {
          dom.textContent = `${data['guestcommitted']}`
          console.log("commiting")
          inputCommitted = this.element.querySelectorAll('input[data-nxt-committed]')[iter]
          iter = iter +1
          if(inputCommited) {
            inputCommited.value = data['guestcommitted']
          }          
        })
    }
  }  

  handleAddedBy() {
    for (const dom of this.element.querySelectorAll('p[data-nxt-added_by]')) {
      fetch(`/api/v1/users/${dom.textContent}`)
        .then(response => response.json())
        .then(data => {
          dom.textContent = `${data['first_name']} ${data['last_name']}`
        })
    }
  }

  resetAddGuest() {
    this.addTarget.reset()
  }

  updateForm(e) {
    let form = e.currentTarget
    let selectSeat = form.querySelector('select[data-nxt-category]')
    let guestId = form.querySelector('input[data-nxt-id]').value
    let inputAllotted = form.querySelector('input[data-nxt-allotted]')
    let inputCommitted = form.querySelector('input[data-nxt-committed]')
    let qCommitted = form.querySelector('q[data-nxt-guestcommitted]')
    

    // update the allotted input after selecting seat tier
    if (e.target.tagName === 'SELECT' && e.target.name === 'seat_id') {
      let seatId = selectSeat.value
      if (seatId) {
        inputAllotted.disabled = false;
        inputCommitted.disabled = false;
        fetch(`${this.urlValue}/${guestId}/tickets?seat_id=${seatId}`)
          .then(response => response.json())
          .then(data => {
            console.log(data)
            if (data.length == 0) {
              inputAllotted.value = 0
              inputCommitted.value = 0
              return
            }

            for (const [_, ticket] of Object.entries(data)) {
              if (ticket['allotted'])
                inputAllotted.value = ticket['allotted'];
              else
                inputAllotted.value = 0;
              if(ticket['committed'])
                inputCommitted.value = ticket['committed'];
              else
                inputCommitted.value = 0;
            }
          })
      } else {
        inputAllotted.value = '';
        inputAllotted.disabled = true;
        inputCommitted.value = '';
        inputCommitted.disabled = true;
      }
    } else {
      let fd = new FormData(form);
      fd.set('checked', fd.get('checked') ? true : false);

      // update guest info
      let guestData = new FormData();
      guestData.append('id', fd.get('id'))
      guestData.append('affiliation', fd.get('affiliation'))
      guestData.set('first_name',fd.get('first_name'))
      guestData.set('last_name',fd.get('last_name'))
      guestData.append('perks', fd.get('perks'))
      guestData.append('comments', fd.get('comments'))
      guestData.append('checked', fd.get('checked'))
      fetch(`${this.urlValue}/${guestId}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('access_token')}`
        },
        method: 'PATCH',
        body: guestData
      })
        .then(response => response.json())

      // update ticket allotment
      if (fd.get('seat_id') !== '') {
        let ticketData = new FormData();
        ticketData.append('seat_id', fd.get('seat_id'));
        ticketData.append('allotted', fd.get('allotted'));
        ticketData.append('committed', fd.get('committed'));
        fetch(`${this.urlValue}/${guestId}/tickets`, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('access_token')}`
          },
          method: 'PATCH',
          body: ticketData
        })
          .then(response => response.json())
      }
    }
  }

  updateSeats() {
    fetch(`${this.seaturlValue}`)
      .then(response => response.json())
      .then(data => {

        let selects = this.seatTargets
        for (const select of selects) {
          let opts = [];
          opts.push(new Option())
          for (const dat of data)
            opts.push(new Option(dat['category'], dat['id'], false, false));

          select.innerHTML = '';
          for (const opt of opts) {
            select.add(opt)
            if (select.getAttribute('data-nxt-category') === opt.value)
              opt.setAttribute('selected', true)
          }
        }
      });
  }
  view_guest_seats(e){
    let form = e.currentTarget
    console.log(form)
    let guestId = form.getAttribute('data-nxt-id')
    console.log("guestId ",guestId)

    fetch(`${this.urlValue}/${guestId}/`)

    .then((response) => {
      response.json().then(
        (data) => {
          console.log(data)
          let name = data.first_name + " " + data.last_name ;
          document.getElementById('guest-name').innerHTML = "Guest : "+name;
        });
    });
    
      fetch(`${this.seaturlValue}`)

      .then((response) => {
        response.json().then(
          (data) => {

            let map_cat_id = new Map();

            data.forEach((itemData) => {
              map_cat_id.set(itemData.id, itemData.category);
            });

            console.log("map_cat_id", map_cat_id)


          fetch(`${this.urlValue}/${guestId}/tickets/`).then((response) => {
            console.log(response);
            response.json().then(
              (data) => {
                console.log(data);
      
                console.log("data",data.length);
      
              if (data.length > 0) {
                var temp = "";
                data.forEach((itemData) => {
                  temp += "<tr>";
                  // temp += "<td>" + itemData.id + "</td>";
                  // temp += "<td>" + itemData.guest_id + "</td>";
                  temp += "<td width=199.8>" + map_cat_id.get(itemData.seat_id) + "</td>";
                  temp += "<td width=199.8>" + itemData.allotted + "</td>";
                  temp += "<td width=199.8>" + itemData.committed + "</td></tr>";
                });
                if(document.getElementById('guest-disp').style.display == 'block'){
                  console.log("inner-contnet",document.getElementById('data-check').innerHTML) 
                  document.getElementById('guest-disp').style.display = 'none';
                }

                else{                
                    document.getElementById('guest-disp').style.display = 'block';
                    document.getElementById('data-check').innerHTML = temp;
      
                console.log("temp", temp)
              }
      
              }
            });
            });

        });
    });
    
  }
}
