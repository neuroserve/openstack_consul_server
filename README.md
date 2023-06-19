# OpenStack Consul Cluster

This will deploy a number of consul instances, which will form a cluster with Consul cloud auto-join.

## Prerequisites

1. You need to create the required images first. Try the openstack-packer repo.
2. You need to deploy a bastion host. Try the openstack-bastion-host repo.

## Deployment

You have to insert the uuid of the network, which was created during creation of the bastion host, into `terraform.tfvars`. Furthermore you have to add the public ip address of your bastion host. The setup uses existing CA files. If you don't have a CA, you can create the required files with `consul tls`. See the [Hashicorp docs](https://developer.hashicorp.com/consul/commands/tls/cert) for more information. The Consul instances are spread over separate hypervisors in order to enhance reliability. If you don't want to federate with other Consul clusters, just comment out the code dealing with floating ip addresses.

Plan and apply by providing the required variables:
`terraform plan -var "auth_url=https://myauthurl.com:5000" -var "user_name=myusername" -var "password=mypassword"` -var "user_domain_name=osdomain" -var "tenant_name=osproject" -var "region=osregion"
All info is needed, in order to join the instances into a Consul cluster.
