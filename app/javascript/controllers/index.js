// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Make Stimulus application available globally for accessing controllers from legacy JS
window.Stimulus = application

// Import all controllers
import AlertAutodismissController from "./alert_autodismiss_controller"
import AlertController from "./alert_controller"
import CardDisplayToggleController from "./card_display_toggle_controller"
import DisableSubmitController from "./disable_submit_controller"
import GridModalController from "./grid_modal_controller"
import CfpDatatableController from "./cfp_datatable_controller"
import CopySpeakerEmailsController from "./copy_speaker_emails_controller"
import DraggableSessionsController from "./draggable_sessions_controller"
import FixedSubnavController from "./fixed_subnav_controller"
import HighlightController from "./highlight_controller"
import InlineEditController from "./inline_edit_controller"
import MaxlengthAlertController from "./maxlength_alert_controller"
import MentionController from "./mention_controller"
import ModalAutofocusController from "./modal_autofocus_controller"
import ModalFormController from "./modal_form_controller"
import NextProposalController from "./next_proposal_controller"
import NotificationsChannelController from "./notifications_channel_controller"
import ProgramSessionsController from "./program_sessions_controller"
import ProposalPreviewController from "./proposal_preview_controller"
import ProposalsTableController from "./proposals_table_controller"
import RatingController from "./rating_controller"
import RemoteModalController from "./remote_modal_controller"
import ReviewerTagsController from "./reviewer_tags_controller"
import ScheduleGridController from "./schedule_grid_controller"
import ScheduleTabsController from "./schedule_tabs_controller"
import StatusToggleController from "./status_toggle_controller"
import ThemeController from "./theme_controller"
import TimeSelectController from "./time_select_controller"
import TimeSlotDialogController from "./time_slot_dialog_controller"
import TimeSlotsController from "./time_slots_controller"
import TomSelectController from "./tom_select_controller"
import TrackFilterController from "./track_filter_controller"

application.register("alert-autodismiss", AlertAutodismissController)
application.register("alert", AlertController)
application.register("card-display-toggle", CardDisplayToggleController)
application.register("disable-submit", DisableSubmitController)
application.register("grid-modal", GridModalController)
application.register("cfp-datatable", CfpDatatableController)
application.register("copy-speaker-emails", CopySpeakerEmailsController)
application.register("draggable-sessions", DraggableSessionsController)
application.register("fixed-subnav", FixedSubnavController)
application.register("highlight", HighlightController)
application.register("inline-edit", InlineEditController)
application.register("maxlength-alert", MaxlengthAlertController)
application.register("mention", MentionController)
application.register("modal-autofocus", ModalAutofocusController)
application.register("modal-form", ModalFormController)
application.register("next-proposal", NextProposalController)
application.register("notifications-channel", NotificationsChannelController)
application.register("program-sessions", ProgramSessionsController)
application.register("proposal-preview", ProposalPreviewController)
application.register("proposals-table", ProposalsTableController)
application.register("rating", RatingController)
application.register("remote-modal", RemoteModalController)
application.register("reviewer-tags", ReviewerTagsController)
application.register("schedule-grid", ScheduleGridController)
application.register("schedule-tabs", ScheduleTabsController)
application.register("status-toggle", StatusToggleController)
application.register("theme", ThemeController)
application.register("time-select", TimeSelectController)
application.register("time-slot-dialog", TimeSlotDialogController)
application.register("time-slots", TimeSlotsController)
application.register("tom-select", TomSelectController)
application.register("track-filter", TrackFilterController)
