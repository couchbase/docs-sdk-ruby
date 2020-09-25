require "couchbase"
include Couchbase # rubocop:disable Style/MixinUsage for brevity

options = Cluster::ClusterOptions.new
# initializes {PasswordAuthenticator} internally
options.authenticate("Administrator", "password")
Cluster.connect("couchbase://localhost", options)

# the same as above, but more explicit
# tag::auth1[]
options.authenticator = PasswordAuthenticator.new("Administrator", "password")
Cluster.connect("couchbase://localhost", options)
# end::auth1[]

# shorter version, more useful for interactive sessions
Cluster.connect("couchbase://localhost", "Administrator", "password")

# authentication with TLS client certificate
# tag::auth2[]
# @see https://docs.couchbase.com/server/current/manage/manage-security/configure-client-certificates.html
options.authenticator = CertificateAuthenticator.new("/tmp/certificate.pem", "/tmp/private.key")
Cluster.connect("couchbases://localhost?trust_certificate=/tmp/ca.pem", options)
# end::auth2[]
