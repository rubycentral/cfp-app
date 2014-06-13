require 'rails_helper'

describe Rating do

  it 'can scope by Event' do
    event1 = create :event, name: 'RubyConf 2013'
    event2 = create :event, name: 'RubyConf 2014'

    proposal_in_event1 = create :proposal, event: event1
    proposal_in_event2 = create :proposal, event: event2

    create :rating, proposal: proposal_in_event1
    create :rating, proposal: proposal_in_event2
    create :rating, proposal: proposal_in_event2

    Rating.for_event(event1).count.should eq(1)
    Rating.for_event(event2).count.should eq(2)
  end

end
