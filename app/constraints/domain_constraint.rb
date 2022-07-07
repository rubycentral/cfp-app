class DomainConstraint
  def matches?(request)
    return false unless request.domain

    !Rails.configuration.events_hosts.match?(request.domain)
  end
end
