import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['replacement', 'element']

  start () {
    const replacement = this.replacementTarget
    replacement.classList.remove('hidden')

    this.elementTarget.replaceWith(replacement)
  }
}
