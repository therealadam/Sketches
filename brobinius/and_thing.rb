class AndThing < Rubinius::AST::Node
  transform :magic, :and_thing, "And thingie"
  
  def self.match?(line, receiver, name, arguments, privately)
    p line
    p receiver
    p name
    p arguments
    p privately
    
    return nil unless name == :'+&&'
    return nil unless receiver.kind_of?(Self)
    p 'here'
    
    nil
  end
  
end