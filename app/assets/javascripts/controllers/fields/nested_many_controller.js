import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "item", "template", "destroyField"]

  static values = {
    associationName: String
  }

  // Add a new nested item
  addItem(event) {
    event.preventDefault()

    // Get the template
    const template = this.templateTarget
    const content = template.innerHTML

    // Replace NEW_RECORD with unique timestamp
    const newId = new Date().getTime()
    const newContent = content.replace(/NEW_RECORD/g, newId)

    // Create a temporary container to parse the HTML
    const temp = document.createElement('div')
    temp.innerHTML = newContent

    // Get the new item element
    const newItem = temp.firstElementChild

    // Insert before the template (which is the last child of container)
    this.containerTarget.insertBefore(newItem, template)

    // Focus the first input in the new item
    const firstInput = newItem.querySelector('input[type="text"], input[type="number"], textarea, select')
    if (firstInput) {
      firstInput.focus()
    }
  }

  // Remove an existing nested item
  removeItem(event) {
    event.preventDefault()

    const item = event.target.closest('[data-nested-many-target="item"]')
    if (!item) return

    const isNewRecord = item.dataset.newRecord === "true"

    if (isNewRecord) {
      // New records can be completely removed from DOM
      item.remove()
    } else {
      // Existing records need to be marked for destruction
      const destroyField = item.querySelector('[data-nested-many-target="destroyField"]')
      if (destroyField) {
        destroyField.value = "1"
      }

      // Hide the item visually
      item.style.display = "none"
    }
  }
}
