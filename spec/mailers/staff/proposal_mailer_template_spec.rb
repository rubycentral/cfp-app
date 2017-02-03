require "rails_helper"

describe Staff::ProposalMailerTemplate do
  include Rails.application.routes.url_helpers

  let(:event) { create(:event) }
  let(:proposal) { create(:proposal, event: event) }

  describe "render" do
    it "passes unknown tags as themselves" do
      template = "::no_tag:: and ::fake_tag::.\n\n::tag_alone::"
      rendered = Staff::ProposalMailerTemplate.new(template, event, proposal).render
      expect(rendered).to match(%r{no_tag and fake_tag})
      expect(rendered).to match(%r{tag_alone})
    end

    it "substitutes proposal title" do
      template = "Line one\n\nLine two with ::proposal_title:: interpolated.\n\nLine three."
      rendered = Staff::ProposalMailerTemplate.new(template, event, proposal).render
      expect(rendered).to match(proposal.title)
    end

    it "substitutes confirmation link" do
      template = "A line with a raw link ::confirmation_link::"
      rendered = Staff::ProposalMailerTemplate.new(template, event, proposal).render
      expect(rendered).to match(%r{raw link http://test.host#{event_proposal_path(event, proposal)}})
    end

    it "only substitutes whitelisted tags" do
      template = "Line one with raw link ::confirmation_link:: and ::proposal_title::"
      rendered =
        Staff::ProposalMailerTemplate.new(template, event, proposal, [:proposal_title]).render
      expect(rendered).to_not match(%r{raw link http://test.host/events/.*?/confirm})
      expect(rendered).to include(proposal.title)
    end
  end
end
