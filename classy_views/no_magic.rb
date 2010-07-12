require 'erb'

class PersonView
  
  def index(people)
    html = <<-HTML
      <div>
        <%= people.map { |p| greet(p) } %>
      </div>
    HTML
    ERB.new(html).result(binding)
  end
  
  def greet(person)
    html = <<-HTML
      <p>Hello, <%= link_to person, url(person) %></p>
    HTML
    ERB.new(html).result(binding)
  end
  
  def method_missing(name, *args, &block)
    filename = "#{name}.html.erb"
    if File.exists?(filename)
      template = File.read(filename)
      
      render = ERB.new(template)
      assigns = if args.first.is_a?(Hash)
        args.first.map { |k, v| "#{k} = args.first[:#{k}]" }
      end
      
      render_binding = binding
      eval(assigns.join("\n"), render_binding)
      eval(render.src, render_binding)
    else
      raise "Template or helper not found: #{name}"
    end
  end
  
  protected
  
  def link_to(text, url)
    "<a href='#{url}'>#{text}</a>"
  end
  
  def url(obj)
    "/#{obj.downcase}"
  end
  
end

view = PersonView.new
# puts view.index(['Adam', 'Courtney'])
puts view.show(:person => 'Adam')
