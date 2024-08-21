consul acl policy create -name anonymous -rules @policies/anonymous-policy.hcl
consul acl token update -id=anonymous -policy-name=anonymous

consul acl policy create -name replication -rules @policies/replication-policy.hcl
consul acl token create -description "ACL replication token" -policy-name replication

consul acl policy create -name "meshgateway" -description "Policy for mesh gateways" -rules @policies/meshgateway-policy.hcl -valid datacenter prod1 -valid-datacenter prod2 -valid-datacenter prod3 -valid-datacenter prod4

consul acl token create -node-identity="consul-gateway-0:prod2"
consul acl token create -description "meshgateway:prod2" -policy-name=meshgateway 

consul acl token create -description "dns-token" -templated-policy "builtin/dns"


consul acl token create -nod-identity="nomad-prod1-0:prod1"
consul acl token create -nod-identity="nomad-prod1-1:prod1"
consul acl token create -nod-identity="nomad-prod1-2:prod1"

consul acl policy create -name "nomad-client" -description "Policy for nomad clients" -rules @policies/nomad-client-policy.hcl -valid-datacenter prod1 -valid-datacenter prod2 -valid-datacenter prod3 -valid-datacenter prod4
consul acl token create -description "nomad client token" -policy-name "nomad-client"

consul acl policy create -name "nomad-server" -description "Policy for nomad servers" -rules @policies/nomad-server-policy.hcl -valid-datacenter prod1 -valid-datacenter prod2 -valid-datacenter prod3 -valid-datacenter prod4
consul acl token create -description "nomad server token" -policy-name "nomad-server"
