class DomainConstraint
  def matches?(request)
    Website.domain_match(request.domain).exists?
  end
end
