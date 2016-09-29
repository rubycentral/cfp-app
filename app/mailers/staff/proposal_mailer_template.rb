class Staff::ProposalMailerTemplate
  include Rails.application.routes.url_helpers

  def initialize(template, event, proposal, tag_whitelist = [])
    @template = template
    @event = event
    @proposal = proposal
    @tags = build_tags(tag_whitelist)
  end

  def render
    replace_simple_tags
    @template.html_safe
  end

  private

  attr_reader :tags

  # ::tag_for_replacement::
  def replace_simple_tags
    @template = @template.gsub(/::([^:]+?)::/) do
      tags[$1] || $1
    end
  end

  def confirmation_link
    event_proposal_url(url_params(event_slug: @event.slug, uuid: @proposal))
  end

  def url_params(hash)
    hash.merge(ActionMailer::Base.default_url_options)
  end

  def build_tags(tag_whitelist)
    whitelist = tag_whitelist.map(&:to_s)

    tags = {
      'proposal_title' => @proposal.title,
      'confirmation_link' => confirmation_link
    }

    tags.select! { |k| whitelist.include?(k) } if whitelist.any?

    tags
  end
end
