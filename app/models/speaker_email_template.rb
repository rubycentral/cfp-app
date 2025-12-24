class SpeakerEmailTemplate
  TYPES = [ :accept, :waitlist, :reject ]

  DISPLAY_TYPES = {
      accept: 'Accept',
      waitlist: 'Waitlist',
      reject: 'Not Accepted'
  }.with_indifferent_access

  TYPES_TO_STATES = {
      accept: :accepted,
      waitlist: :waitlisted,
      reject: :rejected
  }.with_indifferent_access

  attr_accessor :email, :type_key
end
