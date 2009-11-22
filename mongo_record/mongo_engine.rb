require 'rubygems'
$LOAD_PATH << "/Users/adam/dev/sources/ruby/arel/lib"
require 'arel'
require 'mongo'

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
    ['name']
  end
  
  def create(command)
    collection = command.relation.name
    column = command.relation.columns.first
    value = command.record.values.first.value
    
    returning db.collection(collection) << {column => value} do |result|
      log "create: #{result}"
    end
  end
end

def log(msg)
  puts ">> #{msg}"
end

Arel::Table.engine = MongoEngine.new
table = Arel::Table.new('authors')

result = table.insert({:name => 'Glenn'})
