# The problem is, I hate code like this:
#
#   i = 0
#   Post.find_in_batches(:batch_size => 100) do |batch|
#     puts "Processing batch #{i}"
#     process(batch)
#     i = i.succ
#   end
#   
# It's the loop variable that bugs me. And that there are easily noticed
# side-effects. Let's see if we can do better.

# =========
# = Setup =
# =========

require 'rubygems'
require 'active_record'
require 'faker'

database = '/tmp/batches.sqlite3'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3', 
  :database => database)

if File.exists?(database)
  puts "Database already exists"
else
  ActiveRecord::Schema.define do
    create_table :posts do |t|
      t.string :title
      t.text :body
    end
  end
end

class Post < ActiveRecord::Base; end

records = 10_000
if Post.count != records
  time = Benchmark.realtime do
    records.times do
      Post.create(
        :title => Faker::Company.name, 
        :body => Faker::Lorem.paragraphs(3).join("\n"))
    end
  end
  puts "Created #{records} in #{time} seconds"
else
  puts "Database already populated"
end

# ===========
# = Science =
# ===========

# We'll use this as a constant for doing something useful with each post
def process(records)
  total = records.inject(0) do |sum, post|
    sum + post.body.split(" ").length
  end
end

# Here's the typically ugly code. It's got output in it just to demonstrate
# how the ugliness arrives.
i = 0
sum = 0
Post.find_in_batches(:batch_size => 100) do |batch|
  puts "Processing batch #{i}"
  i = i.succ
  puts Benchmark.measure { sum = sum + process(batch) }
end

# Now let's measure how long it runs
i = 0
sum = 0
time = Benchmark.realtime do
  Post.find_in_batches(:batch_size => 100) do |batch|
    i = i.succ
    sum = sum + process(batch)
  end
end
puts "find_in_batches: #{time}s"

# Now, let's introduce a solution. We'll mix this into ActiveRecord::Base.
module EnumerableBatches
  
  def map_in_batches(options={}, &block)
    results = []
    find_in_batches(options) do |batch|
      results << block.call(batch)
    end
    results.flatten
  end
  
  def inject_in_batches(accumulator, options={}, &block)
    find_in_batches(options) do |batch|
      accumulator = block.call(accumulator, batch)
    end
    accumulator
  end
  
end
ActiveRecord::Base.method(:extend).call(EnumerableBatches)

# Here's how we use map
lengths = 0
time = Benchmark.realtime do
  lengths = Post.map_in_batches(:batch_size => 100) do |batch|
    process(batch)
  end
end
puts "map_in_batches: #{time}s"

# Here's how we use inject
time = Benchmark.realtime do
  lengths = Post.inject_in_batches(0, :batch_size => 100) do |sum, batch|
    sum + process(batch)
  end
end
puts "inject_in_batches: #{time}s"
