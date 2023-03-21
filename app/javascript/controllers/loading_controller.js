import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['spinner']

  start () {
    const spinner = document.createElement('div')
    spinner.classList.add('spinner-grow', 'text-primary')

    this.spinnerTarget.replaceWith(spinner)
  }
}
