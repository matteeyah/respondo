import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['parameter']

  static values = {
    mentionPath: String
  }

  addParam (event) {
    event.target.parentNode.href = `${this.mentionPathValue}?ai=${this.parameterTarget.value || 'true'}`
  }
}
