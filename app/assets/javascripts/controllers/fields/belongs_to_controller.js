import { Controller } from "@hotwired/stimulus"
import Combobox from '@github/combobox-nav'
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["id", "dropdown", "input", "label", "list"]

  static values = {
    backendUrl: String
  }

  buildCombobox() {
    return new Combobox(this.inputTarget, this.listTarget)
  }

  connect() {
    this.combobox = this.buildCombobox()

    this.listTarget.addEventListener('combobox-commit', this.handleComboboxCommit.bind(this))
    this.dropdownTarget.hidden = true
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
      this.markSelectedOption()
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

  markSelectedOption() {
    const options = this.listTarget.querySelectorAll('[role="option"]')
    options.forEach((option) => {
      option.removeAttribute('aria-selected')
      const recordId = option.getAttribute('data-id')
      if (recordId === this.idTarget.value) {
        option.setAttribute('aria-selected', 'true')
      }
    })
  }

  selectOption() {
    this.combobox.clearSelection()
    event.target.setAttribute('aria-selected', 'true')

    this.setValuesFromElement(event.target)
  }

  setValuesFromElement(element) {
    const recordId = element.getAttribute('data-id')
    this.idTarget.value = recordId
    this.inputTarget.value = element.textContent.trim()
    this.labelTarget.textContent = element.textContent.trim()
  }

  hide() {
    this.combobox.destroy()
    this.dropdownTarget.hidden = true
  }

  show() {
    this.combobox.start()
    this.dropdownTarget.hidden = false
    this.inputTarget.focus()
  }

  toggle() {
    if (this.dropdownTarget.hidden) {
      this.show()
    } else {
      this.hide()
    }
  }
}
