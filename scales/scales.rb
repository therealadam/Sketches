require "rubygems"
require "active_support/core_ext/module"
require "active_support/concern"

module Scales
  
  mattr_accessor :memcache
  
  module Cache
    extend ActiveSupport::Concern
    
    included do
      def self.cache_by(name)
        # add callbacks to populate, update, and clear the cache
      end
      
      def self.get(*args)
        Scales.memcache.get(key_for(args.first))
      end
      
      def self.key_for(identifier, fragments=[])
        key = [self.class.name.downcase]
        key << fragments if fragments
        key << identifier
        key.flatten.join(":")
      end
      
      after_create :save_to_cache
      after_update :update_cache
      after_destroy :delete_from_cache
    end
    
    protected
    
    def save_to_cache
      # Possible to use JSON?
      Scales.memcache.set(self.class.key_for(id), self)
    end
    
  end
  
end

require "active_record"
require "memcached"

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :username, :null => false
  end
end

class User < ActiveRecord::Base
  
  validates_presence_of :username
  
  include Scales::Cache
  
  cache_by :id
  cache_by :username
  
end

Scales.memcache = Memcached.new("localhost") # Support Moneta someday?

users = %w{peter ray egon winston}.map { |u| User.create(:username => u ) }

p User.get(1)
# User.get(:username => "peter")
