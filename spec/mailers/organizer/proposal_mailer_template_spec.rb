require "rails_helper"

describe Organizer::ProposalMailerTemplate do
  let(:event) { create(:event) }
  let(:proposal) { create(:proposal, event: event) }

  describe "render" do
    it "converts double linefeeds to paragraphs" do
      template = "Line one.\n\nLine two.\nMore line two.\n\nLine three."

      rendered = Organizer::ProposalMailerTemplate.new(template, event, proposal).render
      expect(rendered).to match(%r{^Line one.\n.*?\nLine three.$}m) # multiline match
    end

    it "converts double carriage returns/linefeeds to paragraphs" do
      template = "Line one.\r\n\r\nLine two.\r\nMore line two.\r\n\r\nLine three."

      rendered = Organizer::ProposalMailerTemplate.new(template, event, proposal).render
      expect(rendered).to match(%r{^Line one.\n.*?\nLine three.$}m) # multiline match
    end

    it "passes unknown tags as themselves" do
      template = "::no_tag:: and ::fake_tag::.\n\n::tag_alone::"
      rendered = Organizer::ProposalMailerTemplate.new(template, event, proposal).render
      expect(rendered).to match(%r{no_tag and fake_tag})
      expect(rendered).to match(%r{tag_alone})
    end

    it "substitutes proposal title" do
      template = "Line one\n\nLine two with ::proposal_title:: interpolated.\n\nLine three."
      rendered = Organizer::ProposalMailerTemplate.new(template, event, proposal).render
      expect(rendered).to match(proposal.title)
    end

    it "substitutes confirmation link" do
      template = "Line one with raw link ::confirmation_link:: " +
        "and ::my custom link|confirmation_link:: interpolated.\n\n" +
        "Another ::custom link|confirmation_link:: in the third line."
      rendered = Organizer::ProposalMailerTemplate.new(template, event, proposal).render
      expect(rendered).to match(%r{raw link http://localhost:3000/events/.*?/confirm})
      expect(rendered).to match(%r{<a href='http://localhost:3000/events/.*?/confirm'>my custom link</a>})
      expect(rendered).to match(%r{<a href='http://localhost:3000/events/.*?/confirm'>custom link</a>})
    end

    it "only substitutes whitelisted tags" do
      template = "Line one with raw link ::confirmation_link:: and ::proposal_title::"
      rendered =
        Organizer::ProposalMailerTemplate.new(template, event, proposal, [:proposal_title]).render
      expect(rendered).to_not match(%r{raw link http://localhost:3000/events/.*?/confirm})
      expect(rendered).to include(proposal.title)
    end
  end
end
