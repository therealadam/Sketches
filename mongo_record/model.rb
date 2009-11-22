$LOAD_PATH << "/Users/adam/Organize/Repos/sources/ruby/rails/activemodel/lib"

require 'active_model'
require 'test/unit'
require 'contest'
require 'flexmock/test_unit'

module MongoRecord
  
  def self.included(base)
    base.method(:include).call(InstanceMethods)
    base.extend(ClassMethods)
  end
  
  module InstanceMethods
    
    def initialize
      @saved = false
      @destroyed = false
      @errors = ActiveModel::Errors.new(self)
      super
    end
    
    def new_record?
      @saved
    end
    
    def destroyed?
      @destroyed
    end
    
    def errors
      @errors
    end
    
    def valid?
      # Write me
      true
    end
    
    def save
      database << {:name => 'foo'}
    end
    
  end
  
  module ClassMethods
    def attribute(name)
      class_eval <<-RUBY
        def #{name}
          @#{name}
        end
        
        def #{name}=(val)
          @#{name} = val
        end
      RUBY
    end
  end
  
end

class Person
  
  include ActiveModel::Conversion
  include MongoRecord
  
  attribute :name
  
end

class ModelTest < Test::Unit::TestCase
  
  include ActiveModel::Lint::Tests
  
  def setup
    @model = Person.new
  end
  
  test 'A model defines attributes' do
    assert @model.respond_to?(:name)
    assert @model.respond_to?(:name=)
  end
  
end