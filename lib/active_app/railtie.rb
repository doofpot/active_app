module ActiveApp
  if defined? Rails::Railtie
    class Railtie < Rails::Railtie
      initializer 'active_app.insert_into_active_record' do |app|
        ActiveSupport.on_load :active_record do
          include ActiveApp
        end
      end
    end
  end
end
