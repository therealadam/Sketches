require 'rubygems'
$LOAD_PATH << "/Users/adam/dev/sources/ruby/arel/lib"
require 'arel'
require 'mongo'

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
end

def log(msg)
  puts ">> #{msg}"
end

Arel::Table.engine = MongoEngine.new
Arel::Table.engine.db.collection('authors').clear

table     = Arel::Table.new('authors')
author_id = table.insert({:name => 'Adam'})

p table.first

