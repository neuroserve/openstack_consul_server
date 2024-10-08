locals {
    consul_version="1.19.1"
    envoy_version="1.27.2"
}

variable "auth_url" {
  type    = string
  default = "https://myauthurl5000" 
}

variable "user_name" {
  type    = string
  default = "username" 
}

variable "password" {
  type    = string
  default = "totalgeheim" 
}

variable "tenant_name" {
  type    = string
  default = "myproject"
}

variable "user_domain_name" {
  type    = string
  default = "mydomain"
}

variable "region" {
  type   = string
  default = "myregion"
}


resource "random_uuid" "master_token" {}

#
# This assumes, that you already have a CA - see "consul tls -help" if you don't have one yet
#

resource "tls_private_key" "consul" {
    count = var.config.server_replicas
    algorithm = "RSA"
    rsa_bits  = "4096"
}

resource "tls_cert_request" "consul" {
    count = "${var.config.server_replicas}"
#   key_algorithm   = "${element(tls_private_key.consul.*.algorithm, count.index)}"
    private_key_pem = "${element(tls_private_key.consul.*.private_key_pem, count.index)}"

    dns_names = [
        "consul",
        "consul.local",
        "server.${var.config.datacenter_name}.consul",
        "consul.service.${var.config.domain_name}",
        "consul-${count.index}.server.${var.config.domain_name}.consul",
        "localhost",
        "127.0.0.1",
    ]

    ip_addresses = [
        "127.0.0.1",
    ]

    subject {
        common_name = "server.${var.config.datacenter_name}.consul"
        organization = var.config.organization.name
    }
}

resource "tls_locally_signed_cert" "consul" {
    count = var.config.server_replicas
    cert_request_pem = "${element(tls_cert_request.consul.*.cert_request_pem, count.index)}"
#   ca_key_algorithm = "{(element(tls_cert_request.consul.*.key_algorithm)}"

    ca_private_key_pem = file("${var.config.private_key_pem}")
    ca_cert_pem        = file("${var.config.certificate_pem}")

    validity_period_hours = 8760

    allowed_uses = [
        "cert_signing",
        "client_auth",
        "digital_signature",
        "key_encipherment",
        "server_auth",
    ]
}

resource "random_id" "encryption_key" {
    byte_length = 32
}

data "openstack_images_image_v2" "os" {
  name        = "debian-11-consul"
  visibility  = "private"
  most_recent = "true"
}

resource "openstack_compute_keypair_v2" "user_keypair" {
  name       = "tf_consul"
  public_key = file("${var.config.keypair}")
}

resource "openstack_networking_secgroup_v2" "sg_consul" {
  name        = "sg_consul"
  description = "Security Group for servergroup"
}

resource "openstack_networking_secgroup_rule_v2" "sr_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_dns1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 53
  port_range_max    = 53
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_dns2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 53
  port_range_max    = 53
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_8300tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8300
  port_range_max    = 8300
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_8301tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8301
  port_range_max    = 8301
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_8301udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8301
  port_range_max    = 8301
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_8302tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8302
  port_range_max    = 8302
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_8302udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8302
  port_range_max    = 8302
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_8600tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8600
  port_range_max    = 8600
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_8600udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8600
  port_range_max    = 8600
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_8500tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8500
  port_range_max    = 8500
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_8501tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8501
  port_range_max    = 8501
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_8502tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8502
  port_range_max    = 8502
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}

resource "openstack_networking_secgroup_rule_v2" "sr_8503tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8503
  port_range_max    = 8503
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_consul.id
}


resource "openstack_networking_floatingip_v2" "consul_flip" {
  count = var.config.server_replicas
  pool  = "ext01"
}

resource "openstack_compute_floatingip_associate_v2" "consul_flip" {
   count       = var.config.server_replicas
   floating_ip = "${element(openstack_networking_floatingip_v2.consul_flip.*.address, count.index)}"
   instance_id = "${element(openstack_compute_instance_v2.consul.*.id, count.index)}"
}

resource "openstack_compute_instance_v2" "consul" {
  name            = "consul-${count.index}"
  image_id        = data.openstack_images_image_v2.os.id
  flavor_name     = var.config.flavor_name
  key_pair        = openstack_compute_keypair_v2.user_keypair.name
  count           = var.config.server_replicas
  security_groups = ["sg_consul"]   
  scheduler_hints {
    group = openstack_compute_servergroup_v2.consulcluster.id
  }

#  network {
#    uuid = var.config.instance_backnet_uuid
#  }

  network {
    uuid = var.config.instance_network_uuid
  }
  
  metadata = {
     consul-role = "server"
     public-ipv4 = "${element(openstack_networking_floatingip_v2.consul_flip.*.address, count.index)}"
     ps_restart_after_maint = "true"
  }

  connection {
       type = "ssh"
       user = "root" 
       private_key = file("${var.config.connkey}")
       agent = "true" 
       bastion_host = "${var.config.bastionhost}"
       bastion_user = "debian" 
       bastion_private_key = file("${var.config.connkey}")
       host = self.access_ip_v4
  }

  provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo mkdir -p /etc/consul/certificates",
            "sudo mkdir -p /opt/consul",
            "sudo mkdir -p /etc/consul/policies",
            "sudo useradd -d /opt/consul consul",
            "sudo chown consul /opt/consul",
            "sudo chgrp consul /opt/consul",
        ]
   }

   provisioner "file" {
        content = file("${var.config.certificate_pem}")
        destination = "/etc/consul/certificates/ca.pem"
   }

   provisioner "file" {
        content = tls_locally_signed_cert.consul[count.index].cert_pem
        destination = "/etc/consul/certificates/cert.pem"
   }

   provisioner "file" {
        content = tls_private_key.consul[count.index].private_key_pem
        destination = "/etc/consul/certificates/private_key.pem"
   }

   provisioner "file" {
        content = templatefile("${path.module}/templates/consul.service.tpl", {
            floatingip = "${element(openstack_networking_floatingip_v2.consul_flip.*.address, count.index)}",
        })
        destination = "/etc/systemd/system/consul.service" 
   }

   provisioner "file" {
        content = templatefile("${path.module}/templates/consul-tls.env.tpl", {
            consul_ip = self.access_ip_v4,
        }) 
        destination = "/root/consul-tls.env"
   }

   provisioner "file" {
        source = "${path.root}/files/anonymous-policy.hcl"
        destination = "/etc/consul/policies/anonymous-policy.hcl" 
   }

   provisioner "file" {
        source = "${path.root}/files/policies-tokens.sh"
        destination = "/etc/consul/policies/policies-tokens.sh"
   }

   provisioner "file" {
        source = "${path.root}/files/nomad-client-policy.hcl"
        destination = "/etc/consul/policies/nomad-client-policy.hcl"
   }

   provisioner "file" {
        source = "${path.root}/files/nomad-server-policy.hcl"
        destination = "/etc/consul/policies/nomad-server-policy.hcl"
   }

   provisioner "file" {
        source = "${path.root}/files/meshgateway-policy.hcl"
        destination = "/etc/consul/policies/meshgateway-policy.hcl"
   }

   provisioner "file" {
        source = "${path.root}/files/replication-policy.hcl"
        destination = "/etc/consul/policies/replication-policy.hcl"
   }

   provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y tmux telnet dnsutils",
        ]
   }

   provisioner "file" {
        content = templatefile("${path.module}/templates/consul.hcl.tpl", {
            datacenter_name = var.config.datacenter_name,
            domain_name = var.config.domain_name,
            os_domain_name = var.config.os_domain_name,
            node_name = "consul-${count.index}",
            bootstrap_expect = var.config.server_replicas,
#           encryption_key = random_id.encryption_key.b64_std,
            encryption_key = var.config.consul_encryption_key,            
            upstream_dns_servers = var.config.dns_servers,
            auth_url = "${var.auth_url}",
            user_name = "${var.user_name}",
            password = "${var.password}",
            os_region   = "${var.config.os_region}",
            master_token = random_uuid.master_token.result,
            floatingip = "${element(openstack_networking_floatingip_v2.consul_flip.*.address, count.index)}",
        })
        destination = "/etc/consul/consul.hcl"
   }
   provisioner "remote-exec" {
        inline = [
            "curl -L https://func-e.io/install.sh | bash -s -- -b /usr/local/bin",
            "export ENVOY_VERSION_STRING=${local.envoy_version} ; func-e use $ENVOY_VERSION_STRING",
            "cp /root/.func-e/versions/${local.envoy_version}/bin/envoy /usr/local/bin",
        ]
   }

   provisioner "remote-exec" {
        inline = [
            "cd /tmp ; wget --no-check-certificate https://releases.hashicorp.com/consul/${local.consul_version}/consul_${local.consul_version}_linux_amd64.zip",
            "cd /tmp ; unzip consul_${local.consul_version}_linux_amd64.zip",
            "cd /tmp ; rm consul_${local.consul_version}_linux_amd64.zip",

            "mv /tmp/consul /usr/local/bin/consul",
            "sudo systemctl enable consul",
            "sudo systemctl start consul",
        ]
   }

   provisioner "remote-exec" {
         inline = [
             "sudo apt-get install -y -f dnsmasq",
             "sudo systemctl disable systemd-resolved",
             "sudo systemctl stop systemd-resolved",
         ]
   }

   provisioner "file" {
        source = "${path.root}/files/10-consul.dnsmasq"
        destination = "/etc/dnsmasq.d/10-consul"
   }

   provisioner "file" {
        source = "${path.root}/files/dnsmasq.conf"
        destination = "/etc/dnsmasq.conf"
   }

   provisioner "remote-exec" {
         inline = [
             "sudo systemctl enable dnsmasq",
             "sudo systemctl start dnsmasq",
             "sudo systemctl daemon-reload",
             "sudo systemctl restart dnsmasq &",
         ]
   }
}

resource "openstack_compute_servergroup_v2" "consulcluster" {
  name = "aaf-sg"
  policies = ["soft-anti-affinity"]
}

output "master_token" {
    sensitive = true
    value = random_uuid.master_token.result
}

output "encryption_key" {
    sensitive = true
    value = random_id.encryption_key.b64_std
}
