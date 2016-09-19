module ProgramSessionHelper
  def session_states_collection
    ProgramSession::STATES.map { |state| [state.titleize, state] }
  end
end