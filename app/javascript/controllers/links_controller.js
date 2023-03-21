import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    new Toast(this.element).show()
  }
}
