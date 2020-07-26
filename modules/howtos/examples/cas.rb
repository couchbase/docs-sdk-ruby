# tag::imports[]
require "couchbase"
include Couchbase # to avoid repeating module name
# end::imports[]

options = Cluster::ClusterOptions.new
options.authenticate("Administrator", "password")
cluster = Cluster.connect("couchbase://localhost", options)

collection = cluster.bucket("default").default_collection
collection.upsert("user-id", {"visitCount" => 0})

# tag::handlingerrors[]
max_retries = 10
max_retries.times do
  # get the current document contents
  get_result = collection.get("user-id")

  # increment a count on the user
  content = get_result.content
  content["visitCount"] += 1

  begin
    options = Collection::ReplaceOptions.new
    options.cas = get_result.cas
    collection.replace("user-id", content, options)
    break
  rescue Error::CasMismatch
    # ignore CAS mismatch and try again
    # note: any other exception will break the loop
  end
end
# end::handlingerrors[]

# tag::locking[]
# lock for two seconds
get_and_lock_result = collection.get_and_lock("user-id", 2)
locked_cas = get_and_lock_result.cas

# an example of simply unlocking the document:
# collection.unlock("user-id", locked_cas)

options = Collection::ReplaceOptions.new
options.cas = get_and_lock_result.cas
collection.replace("user-id", "new value", options)
# end::locking[]
