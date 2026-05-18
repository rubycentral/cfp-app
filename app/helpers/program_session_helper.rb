module ProgramSessionHelper
  def session_states_collection
    ProgramSession.states.values.map { |state| [state.titleize, state] }
  end

  def speakers_emails(session)
    session.speakers.map{ |speaker| speaker.email }
  end
end
