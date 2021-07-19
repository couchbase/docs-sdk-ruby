# frozen_string_literal: true

require 'couchbase'

include Couchbase

cluster = Cluster.connect('couchbase://localhost', 'Administrator', 'password')

bucket = cluster.bucket('travel-sample')
collection = bucket.scope('inventory').collection('airline')

puts('Example - [mutate-in]')
# tag::mutate-in[]
collection.mutate_in('airline_10', [
  MutateInSpec.upsert('msrp', 18)
])
# end::mutate-in[]

puts('Example - [lookup-in]')
# tag::lookup-in[]
users_collection = bucket.scope('tenant_agent_00').collection('users')
result = users_collection.lookup_in('1', [
  LookupInSpec.get('credit_cards[0].type'),
  LookupInSpec.get('credit_cards[0].expiration')
])

puts("Card Type: #{result.content(0)}")
puts("Expiry: #{result.content(1)}")
# end::lookup-in[]

# tag::lookup-in-projections[]
options = Collection::GetOptions.new
options.project(%w[credit_cards[0].type credit_cards[0].expiration])
res = users_collection.get('1', options)

puts("Result: #{res.content}")
# end::lookup-in-projections[]

puts('Example - [counters]')
# tag::counters[]
counter_doc_id = 'counter-doc'
# Increment by 1, creating doc if needed.
# By using `initial: 1` we set the starting count(non-negative) to 1 if the document needs to be created.
# If it already exists, the count will increase by 1.
collection.binary.increment(counter_doc_id, Options::Increment(initial: 1))
# Decrement by 1
collection.binary.decrement(counter_doc_id, Options::Decrement())
# Decrement by 5
collection.binary.decrement(counter_doc_id, Options::Decrement(delta: 5))
# end::counters[]

puts('Example - [counters-increment]')
# tag::counters-increment[]
result = collection.get('counter-doc')
value = result.content

increment_amnt = 5
opts = Collection::ReplaceOptions.new
opts.cas = result.cas

puts("Current value: #{value}")
collection.replace('counter-doc', value + increment_amnt, opts) if value.zero?
puts("RESULT: #{value + increment_amnt}")
# end::counters-increment[]
