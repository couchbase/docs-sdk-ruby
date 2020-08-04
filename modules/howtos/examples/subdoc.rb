# tag::imports[]
require "couchbase"
include Couchbase # to avoid repeating module name
# end::imports[]

options = Cluster::ClusterOptions.new
options.authenticate("Administrator", "password")
cluster = Cluster.connect("couchbase://localhost", options)

bucket = cluster.bucket("default")
collection = bucket.default_collection

document = {
    "name" => "Douglas Reynholm",
    "email" => "douglas@reynholmindustries.com",
    "addresses" => {
        "billing" => {
            "line1" => "123 Any Street",
            "line2" => "Anytown",
            "country" => "United Kingdom"
        },
        "delivery" => {
            "line1" => "123 Any Street",
            "line2" => "Anytown",
            "country" => "United Kingdom"
        }
    },
    "purchases" => {
        "complete" => [339, 976, 442, 666],
        "abandoned" => [157, 42, 999]
    }
}
collection.upsert("customer123", document)

# tag::get[]
result = collection.lookup_in("customer123", [
    LookupInSpec.get("addresses.delivery.country")
])
country = result.content(0)
puts "Country = #{country}"
#=> Country = United Kingdom
# end::get[]

# tag::exists[]
result = collection.lookup_in("customer123", [
    LookupInSpec.exists("addresses.delivery.does_not_exist")
])
puts "exists: #{result.exists?(0)}"
#=> exists: false
# end::exists[]

# tag::combine[]
result = collection.lookup_in("customer123", [
    LookupInSpec.get("addresses.delivery.country"),
    LookupInSpec.exists("addresses.delivery.does_not_exist")
])
puts "Country = #{result.content(0)}"
#=> Country = United Kingdom
puts "exists: #{result.exists?(1)}"
#=> exists: false
# end::combine[]

# tag::upsert[]
result = collection.mutate_in("customer123", [
    MutateInSpec.upsert("email", "dougr96@hotmail.com")
])
puts "CAS: #{result.cas}"
#=> CAS: 3769293415702
# end::upsert[]

# tag::insert[]
begin
  collection.mutate_in("customer123", [
      MutateInSpec.insert("email", "dougr96@hotmail.com")
  ])
rescue Error::PathExists
  puts "Error, path already exists"
end
# end::insert[]

# tag::multi[]
result = collection.mutate_in("customer123", [
    MutateInSpec.remove("addresses.billing"),
    MutateInSpec.replace("email", "dougr96@hotmail.com")
])
puts "success: #{result.success?}, CAS: #{result.cas}"
#=> success: true, CAS: 149588684383510
# end::multi[]

# tag::array-append[]
collection.mutate_in("customer123", [
    MutateInSpec.array_append("purchases.complete", [777])
])
complete_purchases = collection.get("customer123").content["purchases"]["complete"]
puts "purchases.complete: #{complete_purchases}"
#=> purchases.complete: [339, 976, 442, 666, 777]
# end::array-append[]

# tag::array-prepend[]
collection.mutate_in("customer123", [
    MutateInSpec.array_prepend("purchases.abandoned", [18])
])
abandoned_purchases = collection.get("customer123").content["purchases"]["abandoned"]
puts "purchases.abandoned: #{abandoned_purchases}"
#=> purchases.abandoned: [18, 157, 42, 999]
# end::array-prepend[]

# tag::array-create[]
collection.upsert("my_array", [])

collection.mutate_in("my_array", [
    MutateInSpec.array_append("", ["some element"])
])
puts "my_array: #{collection.get("my_array").content}"
#=> my_array: ["some element"]
# end::array-create[]

# tag::array-upsert[]
collection.upsert("some_doc", {})

collection.mutate_in("some_doc", [
    MutateInSpec.array_append("some.array", ["hello world"]).create_path
])
puts "some_doc: #{collection.get("some_doc").content}"
#=> some_doc: {"some"=>{"array"=>["hello world"]}}
# end::array-upsert[]

# tag::array-unique[]
collection.mutate_in("customer123", [
    MutateInSpec.array_add_unique("purchases.complete", 95)
])

begin
  collection.mutate_in("customer123", [
      MutateInSpec.array_add_unique("purchases.complete", 95)
  ])
rescue Error::PathExists
  puts "Error, value already exists in the path"
end
# end::array-unique[]

# tag::array-insert[]
collection.upsert("some_doc", {
    "foo" => {
        "bar" => ["hello", "world"]
    }
})

collection.mutate_in("some_doc", [
    MutateInSpec.array_insert("foo.bar[1]", ["cruel"])
])
puts "foo.bar: #{collection.get("some_doc").content["foo"]["bar"]}"
#=> foo.bar: ["hello", "cruel", "world"]
# end::array-insert[]

# tag::counter-inc[]
result = collection.mutate_in("customer123", [
    MutateInSpec.increment("logins", 1)
])

# Counter operations return the updated count
puts "current logins: #{result.content(0)}"
#=> current logins: 1
# end::counter-inc[]

# tag::counter-dec[]
collection.upsert("player432", {"gold" => 1000})

result = collection.mutate_in("player432", [
    MutateInSpec.decrement("gold", 150)
])

# Counter operations return the updated count
puts "player432 has #{result.content(0)} gold coins"
#=> player432 has 850 gold coins
# end::counter-dec[]

# tag::create-path[]
collection.upsert("some_doc", {})

collection.mutate_in("some_doc", [
    MutateInSpec
        .upsert("level_0.level_1.foo.bar.phone",
                {"num" => "0118 999 881 999 119 725 3"})
        .create_path
])

puts "some_doc: #{collection.get("some_doc").content}"
#=> some_doc: {"level_0"=>{"level_1"=>{"foo"=>{"bar"=>{"phone"=>{"num"=>"0118 999 881 999 119 725 3"}}}}}}
# end::create-path[]

# tag::cas[]
get_result = collection.get("player432")

options = Collection::MutateInOptions.new
options.cas = get_result.cas
collection.mutate_in("player432", [
    MutateInSpec.decrement("gold", 150)
], options)
# end::cas[]

# tag::durability[]
options = Collection::MutateInOptions.new
options.durability_level = :majority
collection.mutate_in("some_doc", [
    MutateInSpec.insert("foo", "bar")
])
# end::durability[]
