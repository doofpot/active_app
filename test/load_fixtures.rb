I18n.load_path << File.join(File.dirname(__FILE__), 'files/locales.yml')

ActiveRecord::Base.send(:include, ActiveApp)

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Base.connection.create_table :profiles, force: true do |t|
  t.integer :languages, null: false, default: 0
end

class Profile < ActiveRecord::Base
  application :languages, [:english, :spanish, :chinese, :french, :japanese]
  application :others, [:thing]
end

class SubProfile < Profile
end

class Other < ActiveRecord::Base
  application :others, [:another]
end

Profile.create(languages: [:english])
Profile.create(languages: [:japanese])
Profile.create(languages: [:english, :japanese])
