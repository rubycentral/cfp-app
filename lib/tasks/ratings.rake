namespace :ratings do
  desc "Remove duplicates"
  task :dedup => :environment do
    event = Event.where(slug: "railsconf-2014").first

    event.proposals.each do |proposal|
      proposal_ratings_grouped_by_user = proposal.ratings.select("user_id, max(updated_at) as max_updated_at").group("user_id")
      proposal_ratings_grouped_by_user.each do |ratings_grouped_by_user|
        deleted_count = Rating.delete_all(["proposal_id = ? and user_id = ? and updated_at < ?", proposal.id, ratings_grouped_by_user.user_id, ratings_grouped_by_user.max_updated_at])
        puts "deleted #{deleted_count}: proposal: #{proposal.id} user: #{ratings_grouped_by_user.user_id}" if deleted_count > 0
      end
    end
  end
end
