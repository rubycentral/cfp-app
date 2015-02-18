class Base
  include Rails.application.routes.url_helpers

  def initialize(page)
    @page = page
  end

  def goto_page(link_text)
    @page.click_link link_text
  end

  def current_session
    ::Capybara.current_session
  end

  def create_hash_from_html_table_with_id(id)
    rows = @page.find("table##{id}").all("tr")
    table = rows.map { |r| r.all('th,td').map { |c| c.text.strip } }
    Hash[table[0].zip table[1]]
  end
end
