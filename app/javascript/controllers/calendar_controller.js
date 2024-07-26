import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    dragUpdatePath: String,
    calendarPath: String
  }

  connect() {
    console.log("Setting up calendar interactions")
    this._createDragHandles()
    this._createDropRegions()
  }

  disconect() {
    console.log("Removing calendar interactions")
    this._removeDragHandles()
    this._removeDropRegions()
  }

  _createDragHandles() {
    this._dragstartHandler = this._dragstartHandler.bind(this)
    this.element.querySelectorAll(".calendar-day:has(.start_of_pay_period)").forEach((dayElement) => {
      let dragHandle = document.createElement("div")
      dragHandle.classList.add("drag_handle")
      dragHandle.setAttribute("draggable", true)
      dragHandle.setAttribute("data-pay-period-id", dayElement.querySelector('.pay_period_indicator').getAttribute("data-pay-period-id"))
      dragHandle.addEventListener("dragstart", this._dragstartHandler)
      dayElement.prepend(dragHandle)
    })
  }

  _dragstartHandler(event) {
    event.dataTransfer.dropEffect = "move"
    event.dataTransfer.setData("text/plain", event.target.getAttribute("data-pay-period-id"))
    console.log("drag started, going to update PayPeriod", event.target.getAttribute("data-pay-period-id"))
  }

  _removeDragHandles() {
    this.element.querySelectorAll(".drag_handle").forEach((handle) => {
      handle.remove()
    })
  }

  _createDropRegions() {
    this._dragenterHandler = this._dragenterHandler.bind(this)
    this._dragoverHandler = this._dragoverHandler.bind(this)
    this._dragleaveHandler = this._dragleaveHandler.bind(this)
    this._dropHandler = this._dropHandler.bind(this)
    this.element.querySelectorAll(".calendar-day").forEach((dayElement) => {
      dayElement.addEventListener("dragenter", this._dragenterHandler)
      dayElement.addEventListener("dragover", this._dragoverHandler)
      dayElement.addEventListener("dragleave", this._dragleaveHandler)
      dayElement.addEventListener("drop", this._dropHandler)
    })
  }

  _dragenterHandler(event) {
    event.preventDefault()
    event.target.classList.add("draghover")
  }

  _dragoverHandler(event) {
    event.preventDefault() // Required to enable the drop
  }

  _dragleaveHandler(event) {
    event.preventDefault()
    event.target.classList.remove("draghover")
  }

  _dropHandler(event) {
    const payPeriodId = event.dataTransfer.getData("text/plain")
    const newStartDate = event.target.getAttribute("data-date")
    console.log("drop for PayPeriod", payPeriodId, "onto", newStartDate)
    event.preventDefault()
    event.target.classList.remove("draghover")
    const updateUrl = this.dragUpdatePathValue.replace(":id", payPeriodId) + `?pay_period[start_date]=${newStartDate}`
    const calendarUrl = this.calendarPathValue
    fetch(updateUrl,
        {
          method: "POST",
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
          }
        }
      )
      .then((response) => {
        Turbo.visit(calendarUrl)
      })
  }

  _removeDropRegions() {
    this.element.querySelectorAll(".calendar-day").forEach((dayElement) => {
      dayElement.removeEventListener("dragenter", this._dragenterHandler)
      dayElement.removeEventListener("dragover", this._dragoverHandler)
      dayElement.removeEventListener("dragleave", this._dragleaveHandler)
      dayElement.removeEventListener("drop", this._dropHandler)
    })
  }
}
