require 'rails_helper'

feature "Website Page Management", type: :system do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }
  let!(:website) { create(:website, :with_details, event: event) }

  scenario "Organizer cannot access pages until website is created" do
    skip "FactoryBot 😤"
    website.destroy
    login_as(organizer)

    visit event_path(event)
    within('.navbar') { click_on("Website") }
    within('.website-subnav') { click_on("Pages") }

    expect(page).to have_content(
      "Please configure your website before attempting to create pages"
    )
  end

  scenario "Organizer creates and edits a website page", :js do
    skip "FactoryBot 😤"
    login_as(organizer)

    visit event_path(event)
    within('.navbar') { click_on("Website") }
    within('.website-subnav') { click_on("Pages") }
    click_on "New Page"

    click_on('Save')
    within('.page_name') { expect(page).to have_content("can't be blank") }
    within('.page_slug') { expect(page).to have_content("can't be blank") }

    fill_in('Name', with: 'Home')
    fill_in('Slug', with: 'home')
    fill_in_tinymce(:page, :unpublished_body, 'Come Code With Us')
    click_on('Save')

    expect(page).to have_content('Home Page was successfully created')

    click_on('Home')
    expect(page).to have_content('Edit Home Page')
    fill_in_tinymce(:page, :unpublished_body, :enter)
    fill_in_tinymce(:page, :unpublished_body, 'In Asheville, NC')
    click_on('Save')

    expect(page).to have_content('Home Page was successfully updated')
  end

  scenario "Organizer previews a website page", :js do
    skip "FactoryBot 😤"
    create(:page, unpublished_body: 'Home Content', published_body: nil)
    login_as(organizer)

    visit event_staff_pages_path(event)
    click_on('Preview')

    within_frame('page-preview') do
      expect(page).to have_content('Home Content')
    end
  end

  scenario "Organizer publishes a website page", :js do
    skip "FactoryBot 😤"
    home_page = create(:page, unpublished_body: 'Home Content', published_body: nil)
    login_as(organizer)

    visit page_path(slug: event.slug, page: home_page.slug)
    expect(page).to have_content("Page Not Found")
    visit event_staff_pages_path(event)
    accept_confirm { click_on('Publish') }

    expect(page).to have_content('Home Page was successfully published.')

    click_on('Configuration')
    fill_in('Navigation links', with: "Home\n")
    click_on('Save')

    visit page_path(slug: event.slug, page: home_page.slug)
    expect(page).to have_content('Home Content')
    within('#main-nav') { expect(page).to have_content(home_page.name) }
  end

  scenario "Organizer changes a website landing page", :js do
    skip "FactoryBot 😤"
    create(:page, name: 'Announcement', slug: 'announcement', landing: true)
    home_page = create(:page, name: 'Home', slug: 'home')
    login_as(organizer)

    visit event_staff_pages_path(event)
    accept_confirm { click_on('Promote') }

    expect(page).to have_content('Home Page was successfully promoted.')
    expect(home_page.reload).to be_landing
  end

  scenario "Organizer creates and publishes a splash page from a template", :js do
    skip "FactoryBot 😤"
    login_as(organizer)
    visit new_event_staff_page_path(event)
    select("splash", from: "template")

    click_on('Save')

    accept_confirm { click_on('Publish') }
    click_on('View')

    expect(page).to have_content(event.name)
    expect(page).to have_content(website.city)
    expect(page).not_to have_css('header')
    expect(page).not_to have_css('footer')
  end

  scenario "Organizer hides navigation to a page and hides a page entirely", :js do
    skip "FactoryBot 😤"
    home_page = create(:page, published_body: 'Home Content')
    website.update(navigation_links: [home_page.slug, "schedule"])
    visit page_path(slug: event.slug, page: home_page.slug)
    within('#main-nav') { expect(page).to have_content(home_page.name) }

    login_as(organizer)
    visit edit_event_staff_website_path(event)
    expect(page).to have_content("Navigation links\nHomeSchedule")
    find_field('Navigation links').send_keys(:backspace).send_keys(:backspace)
    fill_in('Navigation links', with: "Schedule\n")
    click_on("Save")

    visit page_path(slug: event.slug, page: home_page.slug)
    within('#main-nav') { expect(page).not_to have_content(home_page.name) }

    visit edit_event_staff_page_path(event, home_page)
    check("Hide page")
    click_on("Save")

    visit page_path(slug: event.slug, page: home_page.slug)
    expect(page).to have_content("Page Not Found")
  end

  scenario "Organizer adds page to a footer category", :js do
    skip "FactoryBot 😤"
    sponsor_page = create(:page, published_body: 'Sponsor', name: 'Sponsor')
    faqs_page = create(:page, published_body: 'Frequently Asked', name: 'FAQs')
    login_as(organizer)

    visit page_path(slug: event.slug, page: sponsor_page.slug)
    within('footer') do
      expect(page).not_to have_content("SOLUTIONS")
      expect(page).not_to have_content("SUPPORT")
      expect(page).not_to have_content('Sponsor')
      expect(page).not_to have_content('FAQs')
    end

    visit edit_event_staff_website_path(event)
    fill_in("Footer categories", with: "Solutions,Support,")
    click_on("Save")
    visit edit_event_staff_page_path(event, sponsor_page)
    select('Solutions', from: 'Footer category')
    click_on("Save")
    visit edit_event_staff_page_path(event, faqs_page)
    select('Support', from: 'Footer category')
    click_on("Save")

    visit page_path(slug: event.slug, page: sponsor_page.slug)
    within('footer') do
      expect(page).to have_content("SOLUTIONS")
      expect(page).to have_content("SUPPORT")
      expect(page).to have_content('Sponsor')
      expect(page).to have_content('FAQs')
    end
  end

  scenario "Organizer switches between editors for page content", :js do
    skip "FactoryBot 😤"
    login_as(organizer)

    visit event_path(event)
    within('.navbar') { click_on("Website") }
    within('.website-subnav') { click_on("Pages") }
    click_on "New Page"

    fill_in('Name', with: 'Home')
    fill_in('Slug', with: 'home')

    initial_text = "Let's Indent Some Code."
    added_text = "TinyMCE should not mess up indenting."

    indented_html = <<~HTML.chomp
      <div>\r
        <p>#{initial_text}</p>\r
      </div>
    HTML

    fill_in_codemirror(indented_html)
    click_on('WYSIWYG')
    fill_in_tinymce(:page, :unpublished_body, added_text)
    click_on('Edit HTML')
    click_on('Save')

    expect(page).to have_content('Home Page was successfully created')
    expected_content = indented_html.gsub(initial_text, "#{initial_text}#{added_text}")
    expect(Page.last.unpublished_body).to eq(expected_content)
  end
end
