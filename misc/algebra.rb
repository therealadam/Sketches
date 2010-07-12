# An attempt to build algebraic data types, like in Haskell.
module Algebraic
  
  def field(name, klass)
    field = Field.new(name, klass)
    define_accessor(field)
    fields << field
  end

  def fields
    @fields ||= []
  end

  def define_accessor(field)
    class_eval <<-RUBY
      def field_values
        @field_values ||= {}
      end

      def #{field.name}
        field_values[#{field.name}]
      end

      def #{field.name}=(val)
        raise TypeError unless val.is_a?(#{field.klass})
        field_values[#{field.name}] = val
      end
    RUBY
  end
  
end

class Field
  attr_accessor :name, :klass

  def initialize(name, klass)
    @name, @klass = name, klass
  end
end

class Example
  extend Algebraic

  field :name, String
  field :age, Fixnum
end
