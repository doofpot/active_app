# ActiveApp - Bit array for ActiveRecord


The original source is from active_flag

```ruby
class Profile < ActiveRecord::Base
  flag :application, [:internal, :external_app_1, :external_2 ]
end

# {:english=>1, :spanish=>2, :chinese=>4, :french=>8, :japanese=>16 }

# Instance methods
profile.application                           #=> #<ActiveApp::Value: {:english, :japanese}>
profile.application.english?                  #=> true
profile.application.set?(:internal)            #=> true
profile.application.unset?(:internal)          #=> false

profile.application.set(:external_app_1)
profile.application.unset(:external_app_2)
profile.application.raw                       #=> 3
profile.application.to_a                      #=> [:external_app_1, :external_app_2]

profile.application = [:external_app_1, :external_app_2]   # Direct assignment that works with forms

# Class methods
Profile.application.maps                      #=> {:internal=>1, :external_app_1=>2, :external_2=>4 }
Profile.application.humans                    #=> {:internal=>"Vertaling 1", :external_app_1=>"Vertaling 2" ...}
Profile.application.pairs                     #=> {"English"=>:english, "Spanish"=>:spanish, "Chinese"=>:chinese, "French"=>:french, "Japanese"=>:japanese}

# Scope methods
Profile.where_application(:external_app_1, :external_2)  #=> SELECT * FROM profiles WHERE languages & 10 > 0
Profile.application.set_all!(:external_2)        #=> UPDATE "profiles" SET languages = COALESCE(languages, 0) | 4
Profile.application.unset_all!(:external_2)      #=> UPDATE "profiles" SET languages = COALESCE(languages, 0) & ~4
```


```

[![Build Status](https://travis-ci.org/kenn/active_app.svg)](https://travis-ci.org/kenn/active_app)

Store up to 64 multiple applications ([bit array](https://en.wikipedia.org/wiki/Bit_array)) in a single integer column with ActiveRecord. From a UI standpoint, it can be used as a  multi-select checkbox storage.

Perfect solution to store multiple boolean values such as preferences, notification settings, achievement status, profile options, etc. in a single column.

* **Single column to group multiple boolean values.** You don't need to have many separate columns. You don't even need a migration when you add a new application item to the list.
* **Fast bitwise operations.** `WHERE languages & 3 > 0` is faster than `WHERE (english = true) OR (spanish = true) OR ...`

If you want a simple enum column, take a look at [EnumAccessor](https://github.com/kenn/enum_accessor).

If you need to work with huge bit arrays, take a look at [Bitwise](https://github.com/kenn/bitwise).

## Usage

```ruby
class Profile < ActiveRecord::Base
  flag :languages, [:english, :spanish, :chinese, :french, :japanese]
end

# {:english=>1, :spanish=>2, :chinese=>4, :french=>8, :japanese=>16 }

# Instance methods
profile.languages                           #=> #<ActiveApp::Value: {:english, :japanese}>
profile.languages.english?                  #=> true
profile.languages.set?(:english)            #=> true
profile.languages.unset?(:english)          #=> false

profile.languages.set(:spanish)
profile.languages.unset(:japanese)
profile.languages.raw                       #=> 3
profile.languages.to_a                      #=> [:english, :spanish]

profile.languages = [:spanish, :japanese]   # Direct assignment that works with forms

# Class methods
Profile.languages.maps                      #=> {:english=>1, :spanish=>2, :chinese=>4, :french=>8, :japanese=>16 }
Profile.languages.humans                    #=> {:english=>"English", :spanish=>"Spanish", :chinese=>"Chinese", :french=>"French", :japanese=>"Japanese"}
Profile.languages.pairs                     #=> {"English"=>:english, "Spanish"=>:spanish, "Chinese"=>:chinese, "French"=>:french, "Japanese"=>:japanese}

# Scope methods
Profile.where_languages(:french, :spanish)  #=> SELECT * FROM profiles WHERE languages & 10 > 0
Profile.languages.set_all!(:chinese)        #=> UPDATE "profiles" SET languages = COALESCE(languages, 0) | 4
Profile.languages.unset_all!(:chinese)      #=> UPDATE "profiles" SET languages = COALESCE(languages, 0) & ~4
```

## Install

```ruby
gem 'active_app'
```

### Migration

Always set `0` as a default.

```ruby
t.integer :languages,                    null: false, default: 0, limit: 8
# OR
add_column :users, :languages, :integer, null: false, default: 0, limit: 8
```

`limit: 8` is only required if you need more than 32 applications.

## Query

For a querying purpose, use `where_[column]` scope.

```ruby
Profile.where_languages(:french)            #=> SELECT * FROM profiles WHERE languages & 8 > 0
```

Also takes multiple values.

```ruby
Profile.where_languages(:french, :spanish)  #=> SELECT * FROM profiles WHERE languages & 10 > 0
```

By default, it searches with `or` operation, so the query above returns profiles that have either French or Spanish.

If you want to change it to `and` operation, you can specify:

```ruby
Profile.where_languages(:french, :spanish, op: :and) #=> SELECT * FROM profiles WHERE languages = 10
```

## Translation

`ActiveApp` supports [i18n](http://guides.rubyonrails.org/i18n.html) just as ActiveModel does.

For instance, create a Japanese translation in `config/locales/ja.yml`

```yaml
ja:
  active_app:
    profile:
      languages:
        english: 英語
        spanish: スペイン語
        chinese: 中国語
        french: フランス語
        japanese: 日本語
```

and now `to_human` method returns a translated string.

```ruby
I18n.locale = :ja
profile.languages.to_human  #=> ['英語', 'スペイン語']

I18n.locale = :en
profile.languages.to_human  #=> ['English', 'Spanish']
```

## Forms

Thanks to the translation support, forms just work as you would expect with the `pairs` convenience method.

```ruby
# With FormBuilder

= form_for(@profile) do |f|
  = f.collection_check_boxes :languages, Profile.languages.pairs

# With SimpleForm

= simple_form_for(@profile) do |f|
  = f.input :languages, as: :check_boxes, collection: Profile.languages.pairs
```

## Other solutions

There are plenty of gems that share the same goal. However they have messy syntax than necessary in my opinion, and I wanted a better API to achieve that goal.

- [bitfields](https://github.com/grosser/bitfields)
- [application_shih_tzu](https://github.com/pboling/application_shih_tzu)

Also, `ActiveApp` has one of the simplest code base that you can easily reason about or hack on.
