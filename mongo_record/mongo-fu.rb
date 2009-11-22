require 'rubygems'
require 'mongo'

conn = Mongo::Connection.new('localhost')
db = conn.db('blog-fu')

authors = db.collection('authors')
authors.clear
authors << {:name => 'Adam Keys'}
