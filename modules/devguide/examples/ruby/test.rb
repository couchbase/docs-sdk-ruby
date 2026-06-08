# frozen_string_literal: true

require 'couchbase'
cluster = Couchbase::Cluster.connect('couchbase://localhost', 'Administrator', 'password')
cluster.bucket('travel-sample')
       .scope('inventory')
       .collection('airport')
       .upsert('foo', { 'bar' => 42 })
