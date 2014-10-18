require 'rails_helper'

describe Tagging do
  describe '.tags_string_to_array' do
    it 'splits comma separated string into tags' do
      expect(Tagging.tags_string_to_array('one,two,three')).to match_array ['one', 'two', 'three']
    end
    it 'strips leading and trailing whitespace from tags' do
      expect(Tagging.tags_string_to_array('  one  , two , three   ')).to match_array ['one', 'two', 'three']
    end
    it 'allows whitespace inside a tag' do
      expect(Tagging.tags_string_to_array('one,two,third element')).to match_array ['one', 'two', 'third element']
    end
    it 'removes extra commas' do
      expect(Tagging.tags_string_to_array(' ,  one,   ,two , ,three,')).to match_array ['one', 'two', 'three']
    end
    it 'removes duplicated tags' do
      expect(Tagging.tags_string_to_array('one,one,two,three')).to match_array ['one', 'two', 'three']
    end
  end

  context '#count_by_tag' do
    let!(:event) { create(:event) }
    let!(:proposal) { create(:proposal, event: event) }

    it 'gives a count for no tags' do
      expect(Tagging.count_by_tag(event)).to eq({})
    end

    it 'gives a count for one tag' do
      create(:tagging, tag: 'intro', proposal: proposal)
      expect(Tagging.count_by_tag(event)).to eq({"intro" => 1})
    end

    it 'gives a count for each tag' do
      create_list(:tagging, 4, tag: "intro", proposal: proposal)
      create_list(:tagging, 5, tag: "advanced", proposal: proposal)

      expect(Tagging.count_by_tag(event)).to eq({"intro" => 4, "advanced" => 5})
    end

    it "only counts tags attached to event" do
      event2 = create(:event)
      proposal2 = create(:proposal, event: event2)

      create_list(:tagging, 5, tag: 'test', proposal: proposal)
      create_list(:tagging, 3, tag: 'test', proposal: proposal2)

      expect(Tagging.count_by_tag(event)['test']).to eq(5)
    end
  end
end
