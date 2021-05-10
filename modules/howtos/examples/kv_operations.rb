# tag::imports[]
require "couchbase"
include Couchbase # to avoid repeating module name
# end::imports[]

cluster = Cluster.connect("couchbase://localhost", "Administrator", "password")

# tag::apis[]
bucket = cluster.bucket("travel-sample")
collection = bucket.scope("_default").collection("_default")
# implicitly use default scope
collection = bucket.collection("_default")
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
collection.replace("my-document", content, Options::Replace(cas: result.cas))
# end::replace[]

# tag::replace-retry[]
id = "my-document"
collection.upsert(id, {"initial" => true})

loop do
  found = collection.get(id)
  content = found.content
  content.update("modified" => true, "initial" => false)
  collection.replace(id, content, Options::Replace(cas: found.cas))
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

begin
  # tag::durability[]
  collection.upsert("my-document", {"doc" => true},
                  Options::Upsert(durability_level: :majority))
  # end::durability[]
rescue Error::DurabilityImpossible
  # Majority durability level requires a multi-node environment.
  # We catch the DurabilityImpossible error to ensure that the example
  # can run successfully on a single node cluster.
  puts "Example requires a multi-node environment"
end

# tag::expiry-insert[]
collection.upsert("my-document", {"doc" => true},
                  Options::Insert(expiry: 2 * 60 * 60))

# or with ActiveSupport::Duration
require 'active_support/core_ext/numeric/time'
collection.upsert("my-document", {"doc" => true},
                  Options::Insert(expiry: 2.hours))

# Time instances also acceptable as absolute time points
expiry = Time.now + 30 # 30 seconds from now
collection.upsert("my-document", {"doc" => true},
                  Options::Insert(expiry: expiry))

# end::expiry-insert[]

# tag::expiry-get[]
found = collection.get("my-document", Options::Get(with_expiry: true))
puts "Expiry of found doc: #{found.expiry_time})"
#=> Expiry of found doc: 2020-07-26 21:52:22 +0300
# end::expiry-get[]

# tag::expiry-replace[]
found = collection.get("my-document", Options::Get(with_expiry: true))

collection.replace("my-document", {"content" => "something new"},
                   Options::Replace(expiry: found.expiry_time))
# end::expiry-replace[]

# tag::expiry-touch[]
collection.get_and_touch("my-document", 24 * 60 * 60)

# or with ActiveSupport::Duration
require 'active_support/core_ext/numeric/time'
collection.get_and_touch("my-document", 1.day)
# end::expiry-touch[]

# tag::named-collection-upsert[]
agent_scope = bucket.scope("tenant_agent_00")
users_collection = agent_scope.collection("users")
document = {"name" => "John Doe", "preferred_email" => "johndoe111@test123.test"}

result = users_collection.upsert("user-key", document)
# end::named-collection-upsert[]
puts "CAS: #{result.cas}"
