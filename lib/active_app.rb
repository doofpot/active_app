require 'active_app/definition'
require 'active_app/railtie'
require 'active_app/value'
require 'active_app/version'
require 'active_record'

module ActiveApp
  extend ActiveSupport::Concern

  module ClassMethods
    def application(column, keys)
      unless respond_to?(:active_apps)
        class_attribute :active_apps
        self.active_apps = {}
      end

      raise "active_apps on :#{column} already defined!" if active_apps[column]

      self.active_apps[column] = Definition.new(column, keys, self)

      # Getter
      define_method column do
        self.class.active_apps[column].to_value(self, read_attribute(column))
      end

      # Setter
      define_method "#{column}=" do |arg|
        write_attribute column, self.class.active_apps[column].to_i(arg)
      end

      # Reference to definition
      define_singleton_method column.to_s.pluralize do
        active_apps[column]
      end

      # Scopes
      define_singleton_method "where_#{column}" do |*args|
        options = args.extract_options!
        integer = active_apps[column].to_i(args)
        column_name = connection.quote_table_name_for_assignment(table_name, column)
        if options[:op] == :and
          where("#{column_name} & #{integer} = #{integer}")
        else
          where("#{column_name} & #{integer} > 0")
        end
      end
    end
  end
end
