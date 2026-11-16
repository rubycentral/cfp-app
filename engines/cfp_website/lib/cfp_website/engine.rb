module CfpWebsite
  class Engine < ::Rails::Engine
    config.to_prepare do
      Event.include CfpWebsite::EventExtension
      TimeSlot.include CfpWebsite::TimeSlotExtension
      SessionFormat.include CfpWebsite::SessionFormatExtension
      ApplicationController.include CfpWebsite::ControllerExtension
      Staff::TimeSlotDecorator.include CfpWebsite::TimeSlotDecoratorExtension
    end

    # Appended so the website catch-all routes come after every core route
    # (a config/routes.rb in the engine would load before the app's).
    initializer 'cfp_website.routes' do |app|
      app.routes.append do
        scope '/events/:event_slug', as: :event do
          namespace :staff do
            draw :staff_website
          end
        end
        draw :website
      end
    end

    initializer 'cfp_website.extension_points' do |app|
      points = app.config.x.extension_points
      points[:head] << 'cfp_website/extensions/head'
      points[:navbar_items] << 'cfp_website/extensions/navbar_item'
      points[:staff_subnav] << 'cfp_website/extensions/staff_subnav'
      points[:time_slot_form_fields] << 'cfp_website/extensions/time_slot_form_fields'
      points[:time_slot_index_filter_headers] << 'cfp_website/extensions/time_slot_index_filter_header'
      points[:time_slot_index_headers] << 'cfp_website/extensions/time_slot_index_header'
      points[:time_slot_index_cells] << 'cfp_website/extensions/time_slot_index_cell'
    end

    # The engine owns ActiveStorage: core has no storage config of its own.
    initializer 'cfp_website.active_storage', before: 'active_storage.services' do |app|
      app.config.active_storage.service ||= CfpWebsite::STORAGE_SERVICES.fetch(Rails.env)
    end

    initializer 'cfp_website.factories', before: 'factory_bot.set_factory_paths' do |app|
      app.config.factory_bot.definition_file_paths << root.join('spec/factories').to_s if app.config.respond_to?(:factory_bot)
    end
  end
end
