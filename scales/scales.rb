require "rubygems"
require "active_support/core_ext/class"
require "active_support/core_ext/module"
require "active_support/concern"

module Scales
  
  mattr_accessor :memcache
  
  module Cache
    extend ActiveSupport::Concern
    
    included do
      
      def self.cache_by(name)
        caches << name
      end
      
      def self.get(fragment, key)
        Scales.memcache.get(key_for(key, fragment))
      end
      
      def self.key_for(identifier, fragments=[])
        key = [self.class.name.downcase]
        key << fragments if fragments
        key << identifier
        key.flatten.join(":")
      end
      
      cattr_accessor(:caches) { [] } # Less ugly way to do this?
      
      after_create :save_to_cache
      after_update :update_cache # TODO
      after_destroy :delete_from_cache # TODO
    end
    
    protected
    
    def save_to_cache
      self.class.caches.each do |key|
        Scales.memcache.set(self.class.key_for(self.send(key), key), self)
      end
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
Scales.memcache.flush

users = %w{peter ray egon winston}.map { |u| User.create(:username => u ) }

p User.get(:id, 2)
p User.get(:username, "peter")
