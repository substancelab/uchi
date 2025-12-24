import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"
import { useClickOutside, useDebounce } from 'stimulus-use'

export default class extends Controller {
  static debounces = ["handleChange"]

  static targets = ["checkbox", "dropdown", "idField", "idsContainer", "input", "label", "list"]

  static values = {
    backendUrl: String
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

    console.log("HasManyController connected. Backend URL:", this.backendUrlValue)
    console.log(this.dropdownTarget)
    this.dropdownTarget.hidden = true
  }

  fetchOptions() {
    console.log("Fetching options for query:", this.inputTarget.value)
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

  selectOption(event) {
    const listItem = event.currentTarget
    const checkbox = listItem.querySelector('input[type="checkbox"]')
    const recordId = listItem.getAttribute('data-id')

    if (!checkbox || !recordId) return

    // Toggle checkbox state
    checkbox.checked = !checkbox.checked

    if (checkbox.checked) {
      this.addId(recordId)
    } else {
      this.removeId(recordId)
    }

    this.updateLabel()
    this.updateCheckboxStates()
  }

  addId(id) {
    const selectedIds = this.getSelectedIds()
    if (selectedIds.includes(id)) return

    // Create a new hidden field for this ID
    const hiddenField = document.createElement('input')
    hiddenField.type = 'hidden'
    hiddenField.name = this.idFieldTargets[0]?.name || this.generateFieldName()
    hiddenField.value = id
    hiddenField.setAttribute('data-has-many-target', 'idField')

    this.idsContainerTarget.appendChild(hiddenField)
  }

  generateFieldName() {
    // Extract the field name from the form structure
    // This is a fallback in case there are no existing idField targets
    const formName = this.element.closest('form')?.querySelector('input[type="hidden"]')?.name
    if (formName) {
      // Match pattern like "model[field_ids][]"
      const match = formName.match(/^([^\[]+\[)([^\]]+)(\]\[\])$/)
      if (match) {
        return formName
      }
    }
    return 'ids[]'
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
    const selectedIds = this.getSelectedIds()

    if (selectedIds.length === 0) {
      this.labelTarget.innerHTML = '<span class="text-body-subtle">Select items...</span>'
      return
    }

    // Get the text from the selected checkboxes
    const selectedTexts = []
    this.checkboxTargets.forEach((checkbox) => {
      if (checkbox.checked) {
        const label = checkbox.closest('label')
        const span = label?.querySelector('span')
        if (span) {
          selectedTexts.push(span.textContent.trim())
        }
      }
    })

    if (selectedTexts.length > 0) {
      this.labelTarget.textContent = selectedTexts.join(', ')
    } else {
      this.labelTarget.innerHTML = `<span class="text-body-subtle">${selectedIds.length} selected</span>`
    }
  }
}
