require 'rails_helper'

# The public file server answers GET /404 with public/404.html before routing,
# so the route itself is pinned here: it must stay ahead of any catch-all.
RSpec.describe 'error page routes', type: :routing do
  it 'routes /404 to the errors controller' do
    expect(get: '/404').to route_to(controller: 'errors', action: 'not_found')
  end
end
