# tag::imports[]
require "couchbase"
include Couchbase # to avoid repeating module name
# end::imports[]

cluster = Cluster.connect("couchbase://localhost", "Administrator", "password")

# tag::apis[]
bucket = cluster.bucket("default")
collection = bucket.scope("myapp").collection("users")
# implicitly use default scope
collection = bucket.collection("users")
# open default collection in default scope
collection = bucket.default_collection
# end::apis[]

collection.upsert("foo", 0)

# tag::increment[]
# increment binary value by 1 (default)
binary_collection = collection.binary
res = binary_collection.increment("foo")
res.content
#=> 1
# end::increment[]

# tag::decrement[]
# decrement binary value by 1 (default)
res = binary_collection.decrement("foo")
res.content
#=> 0
# end::decrement[]

# Increment & Decrement are considered part of the 'binary' API
# and as such may still be a subject to change

# tag::incrementwithoptions[]
# Create a document and assign it to 10 -- counter works atomically
# by first creating a document if it doesn't exist. If it exists,
# the same method will increment/decrement per the "delta" parameter
res = binary_collection.increment("counter",
           Options::Increment(initial: 10, delta: 2))
res.value
#=> 10
#end::incrementwithoptions[]

# Issue the same operation, increment value by 2 to 12
res = binary_collection.increment("counter",
           Options::Increment(initial: 10, delta: 2))
res.value
#=> 12

# tag::decrementwithoptions[]
# Decrement value by 4 to 8
res = binary_collection.decrement("counter",
           Options::Decrement(initial: 10, delta: 4))
res.value
#=> 8
# end::decrementwithoptions[]
