// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Make Stimulus application available globally for accessing controllers from legacy JS
window.Stimulus = application

// Import all controllers
import AlertAutodismissController from "./alert_autodismiss_controller"
import AlertController from "./alert_controller"
import BannerAdsController from "./banner_ads_controller"
import BulkDialogController from "./bulk_dialog_controller"
import BulkDialogShowController from "./bulk_dialog_show_controller"
import CfpDatatableController from "./cfp_datatable_controller"
import ContentController from "./content_controller"
import CopySpeakerEmailsController from "./copy_speaker_emails_controller"
import DatatableController from "./datatable_controller"
import DraggableSessionsController from "./draggable_sessions_controller"
import DropdownController from "./dropdown_controller"
import EditorController from "./editor_controller"
import FilterController from "./filter_controller"
import FixedSubnavController from "./fixed_subnav_controller"
import FlyOutController from "./fly_out_controller"
import GridDayRefreshController from "./grid_day_refresh_controller"
import GridShowModalController from "./grid_show_modal_controller"
import GridTimeSlotRefreshController from "./grid_time_slot_refresh_controller"
import HighlightController from "./highlight_controller"
import InlineEditController from "./inline_edit_controller"
import MaxlengthAlertController from "./maxlength_alert_controller"
import MentionController from "./mention_controller"
import ModalAutofocusController from "./modal_autofocus_controller"
import ModalFormController from "./modal_form_controller"
import MultiselectController from "./multiselect_controller"
import NestedFormController from "./nested_form_controller"
import NextProposalController from "./next_proposal_controller"
import NotificationsChannelController from "./notifications_channel_controller"
import PopoverController from "./popover_controller"
import ProgramSessionsController from "./program_sessions_controller"
import ProposalPreviewController from "./proposal_preview_controller"
import ProposalSelectController from "./proposal_select_controller"
import ProposalsTableController from "./proposals_table_controller"
import RatingController from "./rating_controller"
import RemoteModalController from "./remote_modal_controller"
import ReviewTagsController from "./review_tags_controller"
import ReviewerTagsController from "./reviewer_tags_controller"
import ScheduleGridController from "./schedule_grid_controller"
import ScheduleTabsController from "./schedule_tabs_controller"
import SponsorsFooterController from "./sponsors_footer_controller"
import StatusToggleController from "./status_toggle_controller"
import SubNavController from "./sub_nav_controller"
import TimeSelectController from "./time_select_controller"
import TimeSlotDialogController from "./time_slot_dialog_controller"
import TimeSlotErrorController from "./time_slot_error_controller"
import TimeSlotFormResetController from "./time_slot_form_reset_controller"
import TimeSlotsController from "./time_slots_controller"
import ToggleVisibilityController from "./toggle_visibility_controller"
import TomSelectController from "./tom_select_controller"
import TooltipController from "./tooltip_controller"
import TrackFilterController from "./track_filter_controller"

application.register("alert-autodismiss", AlertAutodismissController)
application.register("alert", AlertController)
application.register("banner-ads", BannerAdsController)
application.register("bulk-dialog", BulkDialogController)
application.register("bulk-dialog-show", BulkDialogShowController)
application.register("cfp-datatable", CfpDatatableController)
application.register("content", ContentController)
application.register("copy-speaker-emails", CopySpeakerEmailsController)
application.register("datatable", DatatableController)
application.register("draggable-sessions", DraggableSessionsController)
application.register("dropdown", DropdownController)
application.register("editor", EditorController)
application.register("filter", FilterController)
application.register("fixed-subnav", FixedSubnavController)
application.register("fly-out", FlyOutController)
application.register("grid-day-refresh", GridDayRefreshController)
application.register("grid-show-modal", GridShowModalController)
application.register("grid-time-slot-refresh", GridTimeSlotRefreshController)
application.register("highlight", HighlightController)
application.register("inline-edit", InlineEditController)
application.register("maxlength-alert", MaxlengthAlertController)
application.register("mention", MentionController)
application.register("modal-autofocus", ModalAutofocusController)
application.register("modal-form", ModalFormController)
application.register("multiselect", MultiselectController)
application.register("nested-form", NestedFormController)
application.register("next-proposal", NextProposalController)
application.register("notifications-channel", NotificationsChannelController)
application.register("popover", PopoverController)
application.register("program-sessions", ProgramSessionsController)
application.register("proposal-preview", ProposalPreviewController)
application.register("proposal-select", ProposalSelectController)
application.register("proposals-table", ProposalsTableController)
application.register("rating", RatingController)
application.register("remote-modal", RemoteModalController)
application.register("review-tags", ReviewTagsController)
application.register("reviewer-tags", ReviewerTagsController)
application.register("schedule-grid", ScheduleGridController)
application.register("schedule-tabs", ScheduleTabsController)
application.register("sponsors-footer", SponsorsFooterController)
application.register("status-toggle", StatusToggleController)
application.register("sub-nav", SubNavController)
application.register("time-select", TimeSelectController)
application.register("time-slot-dialog", TimeSlotDialogController)
application.register("time-slot-error", TimeSlotErrorController)
application.register("time-slot-form-reset", TimeSlotFormResetController)
application.register("time-slots", TimeSlotsController)
application.register("toggle-visibility", ToggleVisibilityController)
application.register("tom-select", TomSelectController)
application.register("tooltip", TooltipController)
application.register("track-filter", TrackFilterController)
