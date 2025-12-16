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
    this.listTarget.addEventListener('combobox-select', this.handleComboboxSelect.bind(this))
  }

  disconnect() {
    this.listTarget.removeEventListener('combobox-commit', this.handleComboboxCommit)
    this.listTarget.removeEventListener('combobox-select', this.handleComboboxSelect)

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

  handleComboboxCommit(e) {
    const recordId = event.target.getAttribute('data-id')
    this.idTarget.value = recordId
  }

  handleComboboxSelect(e) {
    const recordId = event.target.getAttribute('data-id')
    this.idTarget.value = recordId
  }
}
