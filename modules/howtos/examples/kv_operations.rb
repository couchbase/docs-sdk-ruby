# tag::imports[]
require "couchbase"
include Couchbase # to avoid repeating module name
# end::imports[]

options = Cluster::ClusterOptions.new
options.authenticate("Administrator", "password")
cluster = Cluster.connect("couchbase://localhost", options)

# tag::apis[]
bucket = cluster.bucket("default")
collection = bucket.scope("myapp").collection("users")
# implicitly use default scope
collection = bucket.collection("users")
# open default collection in default scope
collection = bucket.default_collection
# end::apis[]

# tag::upsert[]
collection.upsert("document-key", {"author" => "mike"})
# end::upsert[]

# tag::insert[]
begin
  collection.insert("document-key", {"title" => "My Blog Post"})
rescue Error::DocumentExists
  puts "The document already exists!"
end
# end::insert[]

# tag::get-simple[]
begin
  get_result = collection.get("document-key")
  title = get_result.content["title"]
  puts title
  #=> My Blog Post
rescue Error::DocumentExists
  puts "Document not found!"
end
# end::get-simple[]

# tag::get[]
found = collection.get("document-key")
content = found.content
if content["author"] == "mike"
  # do something
else
  # do something else
end
# end::get[]

# tag::replace[]
collection.upsert("my-document", {"initial" => true})

result = collection.get("my-document")
content = result.content
content["modified"] = true
content["initial"] = false
options = Collection::ReplaceOptions.new
options.cas = result.cas
collection.replace("my-document", content, options)
# end::replace[]

# tag::replace-retry[]
id = "my-document"
collection.upsert(id, {"initial" => true})

loop do
  found = collection.get(id)
  content = found.content
  content.update("modified" => true, "initial" => false)
  options = Collection::ReplaceOptions.new
  options.cas = found.cas
  collection.replace(id, content, options)
  break
rescue Error::CasMismatch
  # don't do anything, we'll retry the loop
end
# end::replace-retry[]

# tag::remove[]
begin
  collection.remove("my-document")
rescue Error::DocumentNotFound
  puts "Document did not exist when trying to remove"
end
# end::remove[]

# tag::durability[]
options = Collection::UpsertOptions.new
options.durability_level = :majority
collection.upsert("my-document", {"doc" => true}, options)
# end::durability[]

# tag::expiry-insert[]
options = Collection::InsertOptions.new
options.expiration = 2 * 60 * 60
# or
#   require 'active_support/core_ext/numeric/time'
#   options.expiration = 2.hours
collection.upsert("my-document", {"doc" => true}, options)
# end::expiry-insert[]

# tag::expiry-get[]
options = Collection::GetOptions.new
options.with_expiration = true
found = collection.get("my-document", options)
puts "Expiry of found doc: #{found.expiration} (or #{Time.at(found.expiration)})"
#=> Expiry of found doc: 1595789542 (or 2020-07-26 21:52:22 +0300)
# end::expiry-get[]

# tag::expiry-replace[]
options = Collection::GetOptions.new
options.with_expiration = true
found = collection.get("my-document", options)

options = Collection::ReplaceOptions.new
options.expiration = found.expiration
collection.replace("my-document", {"content" => "something new"}, options)
# end::expiry-replace[]

# tag::expiry-touch[]
collection.get_and_touch("my-document", 24 * 60 * 60)
# or
#   require 'active_support/core_ext/numeric/time'
#   collection.get_and_touch("my-document", 1.day)
# end::expiry-touch[]
