require 'json'

namespace :import do
  desc "Import proposals"
  task :proposals => :environment do
    event = Event.where(slug: 'railsconf2013').first

    data = JSON.parse(File.readlines("./tmp/proposals.json").join("/n"))
    data.each do |proposal|
      Proposal.create({
        event: event,
        title: proposal['title'],
        abstract: proposal['abstract'],
        average_rating: proposal['average_score'],
        created_at: proposal['created_at']
      })
    end
  end
end