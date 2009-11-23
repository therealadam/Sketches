require 'rubygems'
$LOAD_PATH << "/Users/adam/dev/sources/ruby/arel/lib"
require 'arel'
require 'mongo'
require 'pp'

# Not entirely sure if I should define this myself
Column = Struct.new(:name)

class MongoEngine
  
  # ==================
  # = Mongo-specific =
  # ==================
  
  def db
    @conn ||= Mongo::Connection.new('localhost')
    @db   ||= @conn.db('blog-fu')
  end
  
  # ==================
  # = ARel interface =
  # ==================
  
  def columns(table_name, message)
    log message
    @columns ||= ['name'].map do |name|
      Column.new(name)
    end
  end
  
  def create(table)
    collection = table.relation.name
    column     = table.relation.columns.first.name
    value      = table.record.values.first.value
    
    returning db.collection(collection) << {column => value} do |result|
      log "create: #{result}"
    end
  end
  
  def read(table)
    # TODO: return a lazy Enumerable (that responds to first)
    db.collection(table.name).find({}, {:limit => 1}).to_a
  end
  
  def update(command)
    collection = command.relation.name
    
    orig_key = command.assignments.keys.first.value
    orig_value = command.assignments.keys.first.
      relation.predicate.operand2.value
    original = {orig_key => orig_value}
    
    key        = command.assignments.keys.first.value
    value      = command.assignments.values.first.value
    modified   = {key => value}
    
    db.collection(collection).update(original, modified)
  end
  
  def delete(command)
    collection = command.relation.name
    key = command.relation.predicate.operand1.name
    value = command.relation.predicate.operand2.value
    db.collection(collection).remove(key => value)
  end
  
end

def log(msg)
  puts ">> #{msg}"
end

Arel::Table.engine = MongoEngine.new
Arel::Table.engine.db.collection('users').clear

table = Arel::Table.new('users')

if __FILE__ == $PROGRAM_NAME
  author_id = table.insert({:name => 'Adam'})
  p author_id
  
  p table.first
  
  table.where(table[:name].eq('Adam')).update({:name => 'Adam Keys'})
  
  p table.first
  
  table.where(table[:name].eq('Adam Keys')).delete
  
  p table.first
end
