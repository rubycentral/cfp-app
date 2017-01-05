class SpeakerEmailTemplate
  TYPES = [ :accept, :waitlist, :reject ]

  DISPLAY_TYPES = {
      accept: 'Accept',
      waitlist: 'Waitlist',
      reject: 'Not Accepted'
  }.with_indifferent_access

  TYPES_TO_STATES = {
      accept: Proposal::ACCEPTED,
      waitlist: Proposal::WAITLISTED,
      reject: Proposal::REJECTED
  }.with_indifferent_access

  attr_accessor :email, :type_key
end
