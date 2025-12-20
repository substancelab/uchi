import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"
import { useClickOutside, useDebounce } from 'stimulus-use'
import Combobox from '@github/combobox-nav'

export default class extends Controller {
  static debounces = ["handleChange"]

  static targets = ["id", "dropdown", "input", "label", "list"]

  static values = {
    backendUrl: String
  }

  buildCombobox() {
    return new Combobox(this.inputTarget, this.listTarget)
  }

  clickOutside(event) {
    if (!this.dropdownTarget.hidden) {
      this.hide()
    }
  }

  connect() {
    useClickOutside(this, {element: this.dropdownTarget})
    useDebounce(this)

    this.combobox = this.buildCombobox()

    this.listTarget.addEventListener('combobox-commit', this.handleComboboxCommit.bind(this))
    this.dropdownTarget.hidden = true
  }

  disconnect() {
    this.listTarget.removeEventListener('combobox-commit', this.handleComboboxCommit)

    this.combobox.destroy()
  }

  fetchOptions(options) {
    get(this.backendUrlValue, {
      query: { query: this.inputTarget.value }
    }).then(({response}) => {
      return response.text()
    }).then((html) => {
      this.listTarget.innerHTML = html
      this.show()
      this.markSelectedOption()
      if (options?.scrollToSelected) {
        this.scrollToSelectedOption()
      }
    })
  }

  handleChange() {
    this.combobox.stop()
    this.fetchOptions()
  }

  handleComboboxCommit(event) {
    this.setValuesFromElement(event.target)
    this.hide()
  }

  handleFocus() {
    this.fetchOptions({ scrollToSelected: true })
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

  scrollToSelectedOption() {
    const selectedOption = this.listTarget.querySelector('[aria-selected="true"]')
    if (selectedOption) {
      selectedOption.scrollIntoView({
        // Aligns the element at the center of the scrollable container,
        // positioning it in the middle of the visible area.
        block: "center",
        inline: "center",

        // Only the nearest scrollable container is impacted by the scroll.
        container: "nearest"
      })
    }
  }

  selectOption(event) {
    this.combobox.clearSelection()
    event.target.setAttribute('aria-selected', 'true')

    this.setValuesFromElement(event.target)
  }

  setValuesFromElement(element) {
    const recordId = element.getAttribute('data-id')
    this.idTarget.value = recordId
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
