// Entry point for the website engine's JavaScript (built by `yarn build` into
// app/assets/builds/cfp_website.js). Registers the engine's Stimulus
// controllers on the application the core bundle exposes as window.Stimulus,
// so this script must load after application.js (both are module scripts and
// run in document order).

import BannerAdsController from "./controllers/banner_ads_controller"
import ContentController from "./controllers/content_controller"
import EditorController from "./controllers/editor_controller"
import FilterController from "./controllers/filter_controller"
import FlyOutController from "./controllers/fly_out_controller"
import NestedFormController from "./controllers/nested_form_controller"
import SponsorsFooterController from "./controllers/sponsors_footer_controller"
import SubNavController from "./controllers/sub_nav_controller"
import ToggleVisibilityController from "./controllers/toggle_visibility_controller"

const application = window.Stimulus

application.register("banner-ads", BannerAdsController)
application.register("content", ContentController)
application.register("editor", EditorController)
application.register("filter", FilterController)
application.register("fly-out", FlyOutController)
application.register("nested-form", NestedFormController)
application.register("sponsors-footer", SponsorsFooterController)
application.register("sub-nav", SubNavController)
application.register("toggle-visibility", ToggleVisibilityController)
