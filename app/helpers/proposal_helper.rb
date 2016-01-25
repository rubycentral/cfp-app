module ProposalHelper
  def rating_tooltip
      <<-HTML
      <p>Ratings Guide</p>
     <p> 1 - Poor talk with many issues. Not a fit for the event.</p>
     <p> 2 - Mediocre talk that might fit event if they work on it.</p>
     <p> 3 - Good talk, could use improvement but appropriate for the event.</p>
     <p> 4 - Great talk, on topic and an overall fit for the event.</p>
     <p> 5 - Ideal talk, excellent proposal that is a perfect fit for the event.</p>
      HTML
  end
end