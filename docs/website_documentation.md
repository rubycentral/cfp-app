# Website Documentation

You can host a public facing website for your actual conference with CFP App.
As a User with the role of organizer for an event you can create a website by
clicking on the Website tab in the admin interface which will take you to the
configuration page and reveal the sub-navigation for managing other elements of
the event website.

There are two basic types of pages that will comprise an event website. Firstly,
there are "dynamic" pages, namely the Schedule, Program and Sponsor pages which
are populated by actual data entered in CFP app. The Program page is populated
by the program sessions managed in the Program section of CFP app, the Schedule
page is fed by the time slots managed in the Schedule section and the Sponsors
page is managed in the Sponsors sub-navigation area for Website.

Secondly, there are "static" pages. The body content for the static pages are
managed by a custom CMS provided in the Pages section accessible in the Website
sub-navigation. More detailed information about managing static page content can
be found in [Page Content Management](#page-content-management).

## Website Configuration

### General Content

It is recommended that you add some basic general content that will be used in
the header navigation and footer on both dynamic and static pages and may also
show up in static page content that is generated from [Page Templates](#page-templates).

Logo, background and favicon images can be uploaded and will be stored in s3 and
resized as needed using Rails' builtin
[ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html)).
The background image can be used by setting a url for a `background-image` style
in appropriate html tags in static page content. Other general content fields
include:

- City: the city for the event (can include the state if desired).
- Location: the location address for the actual event; can be multiple lines.
- Directions: a link to a direction generating website url for the event.
- Prospectus Link: a link to the prospectus for potential sponsors.

### Navigation and Footer

#### Navigation Links

The navigation links that will appear in the header can be selected and ordered
with this augmented input field. Note that the dynamic pages and any [published
page](#publishing) can be selected from the drop down. The selected pages
can be reordered using drag and drop. Note that the configuration for the entire
form needs to be saved for this information to persist.

#### Footer Categories

Footer categories are custom named categories that various static pages can be
grouped under in the footer section. The order in which these categories will
appear in within the footer can be controlled by drag and drop. **Note that
renaming a category will not update for any page using the old category name**.
You must go and update the footer category for each static page when renaming.

#### Footer content

The remaining fields in this section are as follows:

- Footer about content: populates a content area on the left side of the footer.
  typically used to describe information about the organization hosting the
event. Note that the first line will automatically be styled as a bold title
for the content.
- Footer copyright: appears at the very bottom of the footer
- Twitter handle: just the handle for the event without the '@' sign.
- Facebook url: full url to the facebook page for the event.
- Instagram url: full url to the instagram page for the event.
- Domains: a special field that deserves its own treatment [as follows](#domain-configuration).

### Domain Configuration

Once created, an event website can always be accessed from your cfp-app domain with
the event slug in the path. For example, rubyconf 2022 hosted by Ruby Central
could be accessed at `https://cfp.rubycentral.org/rubyconf-2022`.

However, most conferences will prefer to have a custom domain which can be
achieved by following the steps below. Note that these instructions are for websites
hosted on Heroku but something similar can likely be achieved with whatever
hosted solution being used.

1) Add your custom domain to the Website on the configuration page. Note that
multiple domains can be added by separating them with commas in the input.
Currently only domain matching is supported so do not include any subdomain like
'www' (i.e. just `rubyconf.org`).
2) Add your domain to your heroku hosted cfp-app. This can be done using the
heroku-cli following [these
instructions](https://devcenter.heroku.com/articles/custom-domains) or from the
`Settings` section in the dashboard. Note that you will likely need to configure
SSL certificates as well.
3) You will also need to [Configure your
DNS](https://devcenter.heroku.com/articles/custom-domains#configuring-dns-for-root-domains)
to point to the heroku DNS target for your app.

There is a section in the [routes file](/config/routes.rb/) wrapped with a
`DomainConstraint` that allows the most recent active website to be accessed at
the root of your domain. So, with the example from above, Rubconf 2022 can be
found at `https://rubyconf.org`. Older conferences that share the same domain
can also still be accessed by simply appending the event slug. Hence, Rubyconf
2021 could be reached at `https://rubyconf.org/rubyconf-2021`.

### Configure Website Session Formats

In this section you can select with of your session formats (e.g. Talks,
Workshops, Keynotes) that are created and managed in the event configuration
section of CFP app will appear in the sub navigation for the Program page. You
must check the "Display" field for any session format to appear and can also set
the position and even rename what you want the session format to be called in
the Program sub-navigation.

### Fonts

In this section you can add and remove fonts to be used throughout the
application. You must upload a font file that will be stored in s3 that then
gets dynamically pointed to as a font-family url style in the head section of
the website pages using whatever name you assign to the font.

An unlimited number of fonts can be added though only one primary
and secondary font can be selected at a time. The same font can be both primary
and secondary if desired. The primary font will be used for larger and bolder tags
while the secondary font will be used for body text.

Additional fonts can also be used in static pages as needed and can be
conveniently applied with [Tailwind arbitrary
values](https://tailwindcss.com/docs/font-family#arbitrary-values). If you name
an uploaded font something like `Nasa` then you can use the font by adding the
`font-['Nasa']` class to an html tag.

### Head and Footer Content

Often a website will need to include some custom or third party javascript css
and/or other content in the head or at the end of the body. An area to add such
content has been provided in this section of the Website configuration. You can
add as many of these blocks of code as you wish that will then be inserted on
every page of the website. Be sure to wrap your code in the appropriate tags
(e.g. `<script>`, `<style>`, `<meta>) just as you would in actual html.

One powerful feature is dynamically configuring Tailwind using a head content
block. We are currently self-hosting a copied version of the [play
cdn](https://tailwindcss.com/docs/installation/play-cdn) of tailwind so you can
easily [customize Tailwind](https://tailwindcss.com/docs/configuration) as
needed. We are currently not including [the official
plugins](https://tailwindcss.com/docs/typography-plugin) but we could if
desired!

Using these blocks is currently the best way to [Customize
Colors](#customizing-colors)...

### Customizing Colors

Colors in the app are currently set with css variables which can be easily
overridden in a style tag in a head content block. The css variables in the
default theme can be viewed in the [colors.scss
file](../app/assets/stylesheets/themes/default/colors.scss)

As an example, if you wanted to change the colors for the main content
background and navigation you could add the following content block:

```html
<style>
  :root {
    --body_background_color: var(--yellow);
    --nav_background_color: #ff0000;
    --nav_text_color: var(--yellow);
    --nav_link_hover: var(--yellow);
    --main_content_background: var(--yellow);
  }
</style>
```

Note that a combination of other variables and actual color values were used in
the example.

You can also create some convenience custom classes using these variables with
[Tailwind](https://tailwindcss.com/docs/customizing-colors#using-css-variables).
Try something like this:

```html
  <script>
    function withOpacityValue(variable) {
      return ({ opacityValue }) => {
        if (opacityValue === undefined) {
          return `rgb(var(${variable}))`
        }
        return `rgba(var(${variable}), ${opacityValue})`
      }
    }

    tailwind.config = {
      theme: {
        colors: {
          primary: withOpacityValue('--red'),
          secondary: withOpacityValue('--yellow'),
        }
      }
    }
  </script>
```
and then you use a css class like `bg-primary/75` in your static pages.

## Page Content Management

You can add static pages to your website by navigating to the `Pages` section in
the sub-navigation. You can give your page a `name` and a unique `slug` and add
content using the special editor window provided.

Some pages like a Splash page may not require a header and/or footer as part of
their design. Those can easily be turned off using the `Hide header` and `Hide
footer` checkboxes on the edit form for the page.

On the other hand, if you wish a particular page to show up itself in the footer
then you need to select a `Footer category` for it to appear under.

### Page Templates

To get a quick start on content for standard pages a list of templates can be
selected from at the top of the new page form. This will inject your general
website details into the template and populate the editor window with html that
you can further edit and refine.

### CodeMirror

The initial editor window uses [CodeMirror
5.65.3](https://codemirror.net/index.html) for syntax highlighting and auto
indenting of the html. You may find the [default command key
bindings](https://codemirror.net/doc/manual.html#commands) helpful.

As mentioned earlier in the [Head and Footer Content](#head-and-footer-content)
section, Tailwind is included in the head of every static page so you can use
all standard or any custom configured Tailwind utility classes to style your
page. Of course, any custom inline css styles can be used as well.

### Image Uploading

You can conveniently add images by dragging a file and an image
tag will be placed where you drop it in the editor window. It is best if you
correctly crop, size and optimize your image before uploading though you can
further style it by adding Tailwind or custom styles to the image tag.

### WYSIWYG editing

A user that is not comfortable with editing html can choose instead to use the
[TinyMCE](https://www.tiny.cloud/docs/) wysiwyg editor that can be toggled with
the link below the editor block. Note that this editor has its own opionionated
way of adding and editing the html and it is likely that someone more familiar
with html will need to refine the content that has been added.

### Custom Sponsor Tags

Sponsor information can be embedded into any static page by adding some custom
sponsor tags. Adding a `<sponsors-banner-ads></sponsors-banner-ads>` will add a
rotating banner of the uploaded sponsors ads. Adding
`<sponsors-footer></sponsors-footer>` will provide a complete list of the
sponsors with their logos and description grouped by tiers typically added to
the bottom of a page.

### Saving

Content is **not auto-saved** so be sure to save any wanted changes. As a bit of
insurance, there is a confirm dialog that will ask you whether you want to leave
the page with unsaved changes.

### Previewing

You will notice that a preview version of the page is provided in realtime after
a pause in editing on the right hand side of the editor. A larger preview
version can also be viewed by clicking on the `Preview` button link on the Pages
index page. Note that you are previewing the current unpublished version of the
page.

### Publishing

To actually publish your latest version of the page you must click the `Publish`
button from the Pages index page or the Preview page. This will update what the
public will actually see. If you ever need to hide a published page there is a
`Hide page` checkbox to toggle public access to the page. Note that you will
likely want to remove a hidden page from the [Navigation Links](#navigation-links).
You can easily see which of your pages are currently published and not hidden in
the `Published` column of the Page index page.

Also note that previous versions of the page content are not being saved and
currently cannot be restored. If you wish to preserve previous versions then you
may want to create new versions of a page and rotate the slugs and visibility of
pages.

### Promoting

One page at a time can be promoted to be the landing page accessed by the root
url for the website. Clicking on the `Promote` button on the Pages index page
will promote the selected page. You can see which page is currently promoted in
the `Landing Page` column of the Page index page.

### Hiding the Header or Footer

### Other Buttons

It is probably obvious that you can edit a page by clicking the `Edit` button
from the index page or by clicking on the name or slug for the page. You can
also conveniently access the public facing version of the page using the `View`
button from the index page. Finally, you can fully `Destroy` a page but be
careful since this cannot be undone.

## Sponsors

## Themes

