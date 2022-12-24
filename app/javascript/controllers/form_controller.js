import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  reset () {
    this.element.reset()
  }

  submit () {
    this.element.form.requestSubmit()
  }
}
