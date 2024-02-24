consul acl policy create -name anonymous -rules @policies/anonymous-policy.hcl
consul acl token update -id=anonymous -policy-name=anonymous

consul acl policy create -name replication -rules @policies/replication-policy.hcl
consul acl token create -description "ACL replication token" -policy-name replication

consul acl policy create -name "meshgateway" -description "Policy for mesh gateways" -rules @policies/meshgateway-policy.hcl -valid-datacenter prod2 -valid-datacenter prod3

consul acl token create -node-identity="consul-gateway-0:prod2"
consul acl token create -description "meshgateway:prod2" -policy-name=meshgateway 

