module Proposal::State

  # TODO: Currently a defect exists in the rake db:migrate task that is
  # causing our files to be loaded more than once. Because our files are being
  # loaded more than once, we are receiving errors stating that these
  # constants have already been defined. Therefore, until this defect is
  # fixed, we need to check to ensure that the constants are not already
  # defined prior to defining them.
  unless const_defined?(:ACCEPTED)
    SOFT_ACCEPTED = 'soft accepted'
    SOFT_WAITLISTED = 'soft waitlisted'
    SOFT_REJECTED = 'soft rejected'
    SOFT_WITHDRAWN = 'soft withdrawn'

    ACCEPTED = 'accepted'
    WAITLISTED = 'waitlisted'
    REJECTED = 'rejected'
    WITHDRAWN = 'withdrawn'
    NOT_ACCEPTED = 'not accepted'
    SUBMITTED = 'submitted'

    FINAL_STATES = [ ACCEPTED, WAITLISTED, REJECTED, WITHDRAWN, NOT_ACCEPTED ]

    SOFT_TO_FINAL = {
      SOFT_ACCEPTED => ACCEPTED,
      SOFT_REJECTED => REJECTED,
      SOFT_WAITLISTED => WAITLISTED,
      SOFT_WITHDRAWN => WITHDRAWN
    }
  end
end
