# The other day, I found myself wanting to pass a method from the class
# I was working on to map. Of course, it's easy to use ye olde symbol-to-proc
# hack to call methods on the values in an Enumerable like so:

(1..10).map(&:succ) # => [2, 3, 4, 5, 6, 7, 8, 9, 10, 11]

# But, it's not as simple to call a method that isn't on the object in
# question. OR IS IT?

class Foo
  
  attr_reader :val
  
  def initialize(n)
    @val = n
  end
  
  def go
    (1..10).map(&method(:fancy_incr))
  end
  
  def fancy_incr(i)
    i + val
  end
  
end

# Turns out, if you just know that you can yank a method off an object with
# the aptly named Object#method, it's pretty easy.
Foo.new(4).go # => [5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
