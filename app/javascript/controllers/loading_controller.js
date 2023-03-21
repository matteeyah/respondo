import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['spinner']

  start () {
    console.log('hello')
    const spinner = document.createElement('div')
    spinner.classList.add('dual-ring-spinner')

    this.spinnerTarget.replaceWith(spinner)
  }
}
