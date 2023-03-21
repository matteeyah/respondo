import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['parameter']

  static values = {
    ticketPath: String
  }

  addParam (event) {
    event.target.parentNode.href = `${this.ticketPathValue}?ai=${this.parameterTarget.value || 'true'}`
  }
}
