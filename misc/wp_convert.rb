%w{rubygems data_objects do_mysql}.each { |l| require(l) }

db = 'mysql://localhost/wordpress'

class Post < Struct.new(:id, :title, :date, :body, :excerpt, :categories, :tags)
  def initialize(*args)
    super(*args)
    self.categories = Set.new
    self.tags = Set.new
  end
  
  def inspect
    %Q{#<struct Post id=#{id}, title="#{title}", date=#{date}, categories=<[#{categories.to_a}]>, tags=<[#{tags.to_a}]>, body="#{body}">}
  end

  def jekyll_filename(extension='.textile')
    timestamp = date.strftime('%Y-%m-%d')
    slug = title.split(' ').map { |s| s.gsub(/\W/, '').downcase }.join('-')
    [timestamp, slug].join('-') + extension
  end

  def to_jekyll
    meta = {
      'id' => self.id,
      'title' => self.title.to_s,
      'wp-date' => self.date,
      'wp-excerpt' => self.excerpt.to_s,
      'wp-categories' => self.categories.to_a.join(', '),
      'wp-tags' => self.tags.to_a.join(', '),
      'layout' => 'post'
    }
    
    YAML.dump(meta) << "---\n" << body
  end
end

$post_sql = <<-SQL
SELECT p.ID, 
       p.post_title, 
       p.post_date,
       p.post_content,
       p.post_excerpt
FROM tra_posts AS p
WHERE post_type='post'
  AND post_status='publish'
ORDER BY ID DESC
SQL

$category_sql = <<-SQL
SELECT t.name, tt.taxonomy
FROM tra_term_relationships tr
INNER JOIN tra_term_taxonomy tt
  ON tr.term_taxonomy_id = tt.term_id
INNER JOIN tra_terms t
  ON tt.term_id = t.term_id
WHERE tr.object_id=?
SQL

def load_posts(connection)
  reader = connection.create_command($post_sql).execute_reader
  posts = []
  while reader.next!
    id, title, raw_date, content, excerpt = reader.values
    date = Time.parse(raw_date.to_s)
    posts << Post.new(id, title, date, content, excerpt)
  end
  reader.close
  posts
end

def assign_metadata(connection, post)
  reader = connection.create_command($category_sql).execute_reader(post.id)
  while reader.next!
    name, taxonomy = reader.values
    case taxonomy
    when 'post_tag'
      post.tags << name
    when 'category'
      post.categories << name
    end
  end
  reader.close
end

if (__FILE__ == $0)
  connection = DataObjects::Connection.new(db)

  posts = load_posts(connection)
  posts.each do |post|
    assign_metadata(connection, post)
  end

  posts.each do |post|
    File.open(post.jekyll_filename, 'w') { |f| f.write(post.to_jekyll) }
  end
end

# http://www.sixapart.com/movabletype/docs/mtimport
