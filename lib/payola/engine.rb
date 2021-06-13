module Payola
  class Engine < ::Rails::Engine
    isolate_namespace Payola
    engine_name 'payola'

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    initializer :inject_helpers do |app|
      ActiveSupport.on_load :action_controller do
        ::ActionController::Base.send(:helper, Payola::PriceHelper)
      end

      ActiveSupport.on_load :action_mailer do
        ::ActionMailer::Base.send(:helper, Payola::PriceHelper)
      end
    end

    initializer :configure_subscription_listeners do |app|
      Payola.configure do |config|
        config.subscribe 'invoice.payment_succeeded' do  
          Payola::InvoicePaid
        end
        config.subscribe 'invoice.payment_failed' do 
          Payola::InvoiceFailed
        end
        config.subscribe 'customer.subscription.updated' do
          Payola::SyncSubscription
        end
        config.subscribe 'customer.subscription.deleted' do
          Payola::SubscriptionDeleted
        end
      end
    end
  end
end
