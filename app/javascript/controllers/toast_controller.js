import { Controller } from '@hotwired/stimulus'
import { Toast } from 'bootstrap'

export default class extends Controller {
  connect () {
    new Toast(this.element).show()
  }
}
