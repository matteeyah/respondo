// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

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
    document.getElementById(`toggleButtons${ticketId}`).toggleAttribute('hidden')
    document.getElementById(`${formName}${ticketId}`).toggleAttribute('hidden')
  })
}

window.setupToggleResponseFormsClickListeners = function (ticketId) {
  setupToggleResponseFormsClickListener('toggleReply', 'replyForm', ticketId)
  setupToggleResponseFormsClickListener('toggleInternalNote', 'internalNoteForm', ticketId)
  setupToggleResponseFormsClickListener('reply', 'replyForm', ticketId)
  setupToggleResponseFormsClickListener('internalNote', 'internalNoteForm', ticketId)
  setupToggleResponseFormsClickListener('replyReset', 'replyForm', ticketId)
  setupToggleResponseFormsClickListener('internalNoteReset', 'internalNoteForm', ticketId)
}
