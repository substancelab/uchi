import { Controller } from "@hotwired/stimulus"
import Combobox from '@github/combobox-nav'
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["id", "input", "list"]

  static values = {
    backendUrl: String
  }

  connect() {
    this.combobox = new Combobox(this.inputTarget, this.listTarget)

    this.listTarget.addEventListener('combobox-commit', this.handleComboboxCommit.bind(this))
  }

  disconnect() {
    this.listTarget.removeEventListener('combobox-commit', this.handleComboboxCommit)

    this.combobox.destroy()
  }

  handleChange(e) {
    this.combobox.stop()

    get(this.backendUrlValue, {
      query: { query: this.inputTarget.value }
    }).then(({response}) => {
      return response.text()
    }).then((html) => {
      this.listTarget.innerHTML = html
      this.combobox.start()
    })
  }

  handleComboboxCommit() {
    this.setIdValueFromElement(event.target)
  }

  selectOption() {
    this.combobox.clearSelection()
    event.target.setAttribute('aria-selected', 'true')

    this.setIdValueFromElement(event.target)
  }

  setIdValueFromElement(element) {
    const recordId = element.getAttribute('data-id')
    this.idTarget.value = recordId
  }
}
