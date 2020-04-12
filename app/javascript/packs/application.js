// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Required for use of bootstrap
import 'bootstrap'

require('@rails/ujs').start()
require('turbolinks').start()

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

document.addEventListener('turbolinks:load', (event) => {
  const scrollPositionKey = 'scrollPosition'

  document.querySelectorAll('[data-turbolinks-persist-scroll="true"]').forEach((element) => {
    element.addEventListener('click', () => {
      window.localStorage.setItem(scrollPositionKey, window.scrollY)
    })
  })

  const scrollPosition = window.localStorage.getItem(scrollPositionKey)
  if (scrollPosition) {
    window.scrollTo(0, scrollPosition)
    window.localStorage.removeItem(scrollPositionKey)
  }
})

// Form Toggle click listeners setup
function setupToggleResponseFormsClickListener (buttonName, formName, ticketId) {
  document.getElementById(`${buttonName}${ticketId}`).addEventListener('click', function () {
    document.getElementById(`toggleButtons${ticketId}`).classList.toggle('d-none')
    document.getElementById(`${formName}Form${ticketId}`).toggleAttribute('hidden')
  })
}

window.setupToggleResponseFormsClickListeners = function (ticketId) {
  setupToggleResponseFormsClickListener('toggleReplyFormButton', 'reply', ticketId)
  setupToggleResponseFormsClickListener('toggleInternalNoteButton', 'internalNote', ticketId)
  setupToggleResponseFormsClickListener('replyButton', 'reply', ticketId)
  setupToggleResponseFormsClickListener('internalNoteButton', 'internalNote', ticketId)
  setupToggleResponseFormsClickListener('replyReset', 'reply', ticketId)
  setupToggleResponseFormsClickListener('internalNoteReset', 'internalNote', ticketId)
}
