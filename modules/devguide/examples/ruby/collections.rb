# frozen_string_literal: true

require 'couchbase'

include Couchbase

cluster = Cluster.connect('couchbase://localhost', 'Administrator', 'password')

bucket = cluster.bucket('travel-sample')

collection_mgr = bucket.collections

# create collection in default scope
collection_spec = Management::CollectionSpec.new do |spec|
  spec.name = 'bookings'
  spec.scope_name = '_default'
end

collection_mgr.create_collection(collection_spec)
# end::create-collection[]

# tag::collections_1[]
bucket.collection('bookings') # in default scope
# end::collections_1[]
#
# tag::collections_2[]
bucket.scope('tenant_agent_00').collection('bookings')
# end::collections_2[]

print('Done.')
