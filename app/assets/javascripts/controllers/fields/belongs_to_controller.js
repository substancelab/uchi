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

  fetchOptions() {
    get(this.backendUrlValue, {
      query: { query: this.inputTarget.value }
    }).then(({response}) => {
      return response.text()
    }).then((html) => {
      this.listTarget.innerHTML = html
      this.show()
    })
  }

  handleChange() {
    this.combobox.stop()
    this.fetchOptions()
  }

  handleComboboxCommit() {
    this.setValuesFromElement(event.target)
    this.hide()
  }

  handleFocus() {
    this.fetchOptions()
  }

  selectOption() {
    this.combobox.clearSelection()
    event.target.setAttribute('aria-selected', 'true')

    this.setValuesFromElement(event.target)
    this.hide()
  }

  setValuesFromElement(element) {
    const recordId = element.getAttribute('data-id')
    this.idTarget.value = recordId
    this.inputTarget.value = element.textContent.trim()
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
