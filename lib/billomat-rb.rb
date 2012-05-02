require 'rubygems'
gem 'activeresource', '>=3.2.3'
gem 'activesupport', '>=3.2.3'
require 'active_support'
require 'active_resource'

=begin
A Ruby library for interacting with the RESTful Billomat API

# Initializing

To initialize the Billomat API, you need your account name and an API key. Information
on how this key can be obtain can be found [here](http://www.billomat.com/en/api/basics/),
in the **Authentication** section.

    require 'billomat-rb'

    Billomat.account = "<insert your account name here>"
    Billomat.key = "<insert your api key here>"

    puts Billomat.validate! # Should return true at this point

# Resources

All the following examples assume you have initialized the API properly.

## Settings

The Billomat API currently only supports retrieving all settings at once:

    Billomat.res(:settings).find

will yield

    => #<Billomat::Resources::Settings:0x007fc850b1e138 @attributes={...} prefix_options={}, @persisted=true>

Modifying settings is also supported:

    x = Billomat.res(:settings).find
    x.currency_code = "USD"
    x.save # => true


=end
module Billomat

  class << self
    attr_writer :resources

    # Contains an array of loaded resource classes (sub-classes of
    # ActiveResource::Base) that implement Billomat API methods. Shouldn't be
    # accessed directly as it is only necessary for internal use.
    # @return [Array]
    #
    def resources
      @resources ||= []
    end


    # Updating the Billomat account name updates all loaded resources with the
    # respective new API URL (there is a API subdomain for every account
    # ([read more](http://www.billomat.com/en/api/basics/)).
    #
    attr_reader :account

    # See `attr_reader :account`
    def account=(name)
      resources.each do |klass|
        klass.site = @host_format % [@protocol, @domain_format % name, ":#{@port}", @api_path]
      end
      @account = name
    end


    # Holds the API authentication key. Updating this attribute will remove previously
    # set authentication information.
    # @return [String]
    #
    attr_reader :key

    # Sets the api key for all resource
    # Removes all earlier authentication info
    def key=(value)
      resources.each do |klass|
        klass.headers['X-BillomatApiKey'] = value
      end
      @key = value
    end


    # Tries to connect to the Billomat API
    # @return [bool] True if the connection attempt was successful, otherwise false
    # @raise [Exception] May raise an exception if an error occurred
    def validate!
      !!Billomat.res(:myself).find
    end


    # Resets the Billomat API to a "clean" state, that is, with no account or key
    # assigned to it.
    #
    # @return [void]
    #
    def reset!
      resources.each do |klass|
        klass.site = nil
        klass.headers.delete 'X-BillomatApiKey'
      end
      @account = nil
      @key = nil
    end


    # Fetches an available API resource class, previously checking if the Billomat class
    # has been initialized and is ready to be used (because if uninitialized, API calls
    # result in difficult-to-debug error messages. Therefore it is recommended to use this
    # method instead of accessing the resources directly).
    #
    # @return [Billomat::Base]
    #
    def res(resource)
      raise NotInitializedError.new("Billomat account or key was not set!") if @account.nil? or @key.nil?

      resource = resource.to_s.capitalize.to_sym
      raise ArgumentError.new("Unknown resource type '#{resource}'") if not Billomat::Resources.constants.include? resource

      Billomat::Resources.const_get(resource)
    end


  end

  @host_format   = '%s://%s%s%s' # protocol :// domain_format port path
  @domain_format = '%s.billomat.net'
  @api_path      = '/api'
  @protocol      = 'http'
  @port          = '80'

end


"""
TODO: Understand this ActiveSupport monkey-patch and implement the same functionality
for ActiveSupport 3.2.3

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Hash #:nodoc:
      module Conversions
        def self.included(klass)
          klass.extend(ClassMethods)
        end

        module ClassMethods

          private

          # Dirty monkey patching indeed
          def typecast_xml_value_with_array_fix(value)
            value.delete('total')
            value.delete('type')
            value.delete('per_page')
            value.delete('page')
            typecast_xml_value_without_array_fix(value)
          end

          alias_method_chain :typecast_xml_value, :array_fix
        end
      end
    end
  end
end
"""


require File.dirname(__FILE__) + '/billomat/exceptions'
require File.dirname(__FILE__) + '/billomat/resource_types'
require File.dirname(__FILE__) + '/billomat/base'
require File.dirname(__FILE__) + '/billomat/singleton_base'
require File.dirname(__FILE__) + '/billomat/read_only_singleton_base'

require File.dirname(__FILE__) + '/billomat/resources/settings'
require File.dirname(__FILE__) + '/billomat/resources/users'
require File.dirname(__FILE__) + '/billomat/resources/myself'
require File.dirname(__FILE__) + '/billomat/resources/clients'
require File.dirname(__FILE__) + '/billomat/resources/unit'
