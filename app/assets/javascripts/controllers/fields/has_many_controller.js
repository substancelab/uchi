import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"
import { useClickOutside, useDebounce } from 'stimulus-use'

export default class extends Controller {
  static debounces = ["handleChange"]

  static targets = ["checkbox", "dropdown", "idField", "idsContainer", "input", "label", "list"]

  static values = {
    backendUrl: String,
    fieldName: String
  }

  clickOutside(event) {
    if (!this.dropdownTarget.hidden) {
      this.closeDropdown()
    }
  }

  closeDropdown() {
    this.dropdownTarget.hidden = true
  }

  connect() {
    useClickOutside(this, {element: this.dropdownTarget})
    useDebounce(this)

    this.dropdownTarget.hidden = true
  }

  fetchOptions() {
    get(this.backendUrlValue, {
      query: { query: this.inputTarget.value }
    }).then(({response}) => {
      return response.text()
    }).then((html) => {
      this.listTarget.innerHTML = html
      this.openDropdown()
      this.updateCheckboxStates()
    }).catch((error) => {
      console.error("Failed to fetch options:", error)
      this.dropdownTarget.hidden = true
    })
  }

  getSelectedIds() {
    return this.idFieldTargets.map(field => field.value)
  }

  handleChange() {
    this.fetchOptions()
  }

  handleFocus() {
    this.fetchOptions()
  }

  openDropdown() {
    this.dropdownTarget.hidden = false
    this.inputTarget.focus()
  }

  handleCheckboxChange(event) {
    const checkbox = event.target
    const listItem = checkbox.closest('li[data-id]')
    const recordId = listItem?.getAttribute('data-id')

    if (!recordId) return

    if (checkbox.checked) {
      // Get the title from the label
      const label = listItem?.querySelector('label')
      const title = label ? label.textContent.trim() : ''
      this.addId(recordId, title)
    } else {
      this.removeId(recordId)
    }

    this.updateLabel()
  }

  addId(id, title) {
    const selectedIds = this.getSelectedIds()
    if (selectedIds.includes(id)) return

    // Create a new hidden field for this ID
    const hiddenField = document.createElement('input')
    hiddenField.type = 'hidden'
    hiddenField.name = this.fieldNameValue
    hiddenField.value = id
    hiddenField.setAttribute('data-has-many-target', 'idField')
    hiddenField.setAttribute('data-title', title)

    this.idsContainerTarget.appendChild(hiddenField)
  }

  removeId(id) {
    const field = this.idFieldTargets.find(f => f.value === id)
    if (field) {
      field.remove()
    }
  }

  toggle() {
    if (this.dropdownTarget.hidden) {
      this.openDropdown()
    } else {
      this.closeDropdown()
    }
  }

  updateCheckboxStates() {
    const selectedIds = this.getSelectedIds()

    this.checkboxTargets.forEach((checkbox) => {
      const listItem = checkbox.closest('li[data-id]')
      if (!listItem) return

      const recordId = listItem.getAttribute('data-id')
      const isSelected = selectedIds.includes(recordId)

      checkbox.checked = isSelected

      if (isSelected) {
        listItem.setAttribute('aria-selected', 'true')
      } else {
        listItem.removeAttribute('aria-selected')
      }
    })
  }

  updateLabel() {
    // Get titles from the hidden fields (which persist even when items are filtered)
    const titles = this.idFieldTargets
      .map(field => field.getAttribute('data-title'))
      .filter(title => title) // Remove empty titles

    if (titles.length === 0) {
      this.labelTarget.innerHTML = '<span class="text-body-subtle">Select items...</span>'
      return
    }

    this.labelTarget.textContent = titles.join(', ')
  }
}
