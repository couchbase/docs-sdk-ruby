#tag::DocumentNotFound[]
begin
  collection.replace("my-key", {"foo" => 42})
rescue Couchbase::Error::DocumentNotFound => ex
  # key does not exist, report and continue
  puts ex
end
#end::DocumentNotFound[]

#tag::DocumentExists[]
begin
  collection.insert("my-key", {"foo" => 32})
rescue Couchbase::Error::DocumentExists => ex
  # key already exists, report and continue
  puts ex
end
#end::DocumentExists[]

#tag::CasMismatch[]
begin
  result = collection.get("my-key")
  options = Couchbase::Collection::ReplaceOptions.new
  options.cas = result.cas
  collection.replace("my-key", {"foo" => 42}, options)
rescue Couchbase::Error::CasMismatch => ex
  # the CAS value has changed
  puts ex
end
#end::CasMismatch[]

#tag::DurabilityAmbiguous[]
begin
  options = Couchbase::Collection::UpsertOptions.new
  options.durability_level = :persist_to_majority
  collection.upsert("my-key", {"foo" => 42}, options)
rescue Couchbase::Error::DurabilityAmbiguous => ex
  # durable write request has not completed, it is unknown whether the request met the durability requirements or not
  puts ex
end
#end::DurabilityAmbiguous[]

#tag::DurabilityLevelNotAvailable[]
begin
  options = Couchbase::Collection::UpsertOptions.new
  options.durability_level = :persist_to_majority
  collection.upsert("my-key", {"foo" => 42}, options)
rescue Couchbase::Error::DurabilityLevelNotAvailable => ex
  # cluster not able to meet durability requirements
  puts ex
end
#end::DurabilityLevelNotAvailable[]
