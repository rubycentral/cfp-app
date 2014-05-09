namespace :ratings do
  desc "Remove duplicates"
  task :dedup => :environment do
    event = Event.where(slug: "railsconf-2014").first

    event.proposals.each do |proposal|
      proposal_ratings_grouped_by_person = proposal.ratings.select("person_id, max(updated_at) as max_updated_at").group("person_id")
      proposal_ratings_grouped_by_person.each do |ratings_grouped_by_person|
        deleted_count = Rating.delete_all(["proposal_id = ? and person_id = ? and updated_at < ?", proposal.id, ratings_grouped_by_person.person_id, ratings_grouped_by_person.max_updated_at])
        puts "deleted #{deleted_count}: proposal: #{proposal.id} person: #{ratings_grouped_by_person.person_id}" if deleted_count > 0
      end
    end
  end
end