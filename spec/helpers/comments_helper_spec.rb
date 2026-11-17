require 'rails_helper'

describe CommentsHelper, type: :helper do
  let(:proposal) { create(:proposal_with_track) }
  let(:speaker) { create(:speaker, proposal: proposal) }
  let(:comment) { create(:comment, proposal: proposal, user: speaker.user) }

  before { helper.singleton_class.define_method(:program_mode?) { false } }

  it 'labels the speaker as speaker on a blind event' do
    proposal.event.update!(blind_review: true)
    expect(helper.commenter_name(comment)).to eq('speaker')
  end

  it 'names the speaker otherwise' do
    expect(helper.commenter_name(comment)).to eq(speaker.user.name)
  end
end
