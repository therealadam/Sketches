# Goal: render view-ish things using pure Ruby objects
# 
# Principles:
#   * Everything is a method call (methods return results, methods take parameters, etc.)
#   * Avoid invented languages (i.e. special ways to define methods or pass arguments)
#   * Promote defining logic in the object and loading simple templates from disk (method_missing loads a template from disk)
# 
# Challenges:
#   * Need to wrap the actual method with something to do the actual template render (ERB)
#   * Preserving argument names probably requires either macros or a special language for specifying the expected argument names

require 'erb'

module ViewObject
  module ClassMethods
    
    def renders(*methods)
      methods.each do |m|
        original = "__#{m}"
        
        class_eval do
          alias_method original, m
          define_method(m) do |args|
            raise ArgumentError.new("Expected a params hash") unless args.is_a?(Hash)
            render = ERB.new(send(original.to_sym))
            assigns = args.map { |(k, v)| "#{k} = args[:#{k}]" }
            
            render_binding = binding
            eval(assigns.join("\n"), render_binding)
            eval(render.src, render_binding)
          end
        end
      end
    end
    
  end
  
  def self.included(receiver)
    receiver.extend ClassMethods
  end
  
end

class PersonView
  
  include ViewObject
  
  attr_reader :people
  
  def initialize(people)
    @people = people
  end
  
  # AKK: it'd be nice if parameters were passed with normal Ruby semantics
  def index
    <<-HTML
      <div>
        <%= blah %>
        <%= people.map { |p| person(:p => p) } %>
      </div>
    HTML
  end
  
  def person
    <<-HTML
      <div>
        <h1><%= p.name %></h1>
        
        <p><%= link_to p.address, url(p) %></p>
      </div>
    HTML
  end
  
  renders :index, :person
  
  protected
  
  def link_to(text, url)
    "<a href='#{url}'>#{text}</a>"
  end
  
  def url(obj)
    "/"
  end

end

Person = Struct.new(:name, :address)
person = Person.new('Adam Keys', 'Dallas, TX')
view = PersonView.new([person])
puts view.index(:blah => 'blah')
