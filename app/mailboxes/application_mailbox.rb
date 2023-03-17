# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  INBOUND_REGEX = /inbound\+(\d+)@mail\.respondohub\.com/

  routing INBOUND_REGEX => :inbound
end
