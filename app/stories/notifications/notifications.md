As an authenticated user
I want to see an envelope icon in the nav bar
That gives me a dropdown menu showing any new comments,
(listed as 'Internal comment' if it's between  review committee staff members),
An option to 'Mark all as read' if I have comments,
And an option to 'View all notifications'

/notifications

As an authenticated user
I want to visit 'View all notifications'
And see a table with each comment showing:
What proposal the new or internal comment is for,
When the comment was left,
And a link to view that comment.

events/:slug/staff/proposals/:id

When I visit the link to view proposal comments
(either from the dropdown or from the notifications page)
I want to see all comments for that proposal along with all other proposal info
So that I may interact with those comments if I choose to do so.
