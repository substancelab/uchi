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
    this.listTarget.hidden = true
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
      this.show()
    })
  }

  handleComboboxCommit() {
    this.setIdValueFromElement(event.target)
    this.hide()
  }

  selectOption() {
    this.combobox.clearSelection()
    event.target.setAttribute('aria-selected', 'true')

    this.setIdValueFromElement(event.target)
    this.hide()
  }

  setIdValueFromElement(element) {
    const recordId = element.getAttribute('data-id')
    this.idTarget.value = recordId
  }

  hide() {
    this.combobox.destroy()
    this.listTarget.hidden = true
  }

  show() {
    this.combobox.start()
    this.listTarget.hidden = false
  }
}
