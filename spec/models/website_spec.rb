require 'rails_helper'

describe Event do
  describe '.domain_match' do
    it 'returns website that match a domain' do
      rubyconf = create(:website, domains: 'www.rubyconf.org')
      _otherconf = create(:website)
      expect(Website.domain_match('rubyconf.org')).to contain_exactly(rubyconf)
    end
    it 'returns website that match one of multiple domains' do
      rubyconf = create(:website, domains: 'www.rubyconf.org,www.rubyconf.com')
      _otherconf = create(:website)
      expect(Website.domain_match('rubyconf.com')).to contain_exactly(rubyconf)
    end
  end
end
