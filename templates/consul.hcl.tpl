    datacenter = "${datacenter_name}"
#   primary_datacenter = "${datacenter_name}"
    data_dir   = "/opt/consul"
    log_level  = "INFO"
    node_name  = "${node_name}"
    server     =  true
    bootstrap_expect = ${bootstrap_expect}
    retry_join = ["provider=os tag_key=consul-role tag_value=server auth_url=${auth_url} user_name=${user_name} domain_name=${os_domain_name} password=\"${password}\" region=${os_region}"] 
    ports { 
        http      = -1
        https     = 8501
        grpc      = 8502
        grpc_tls  = 8503
    }
    ui_config {
        enabled = true
    }
    encrypt        = "${encryption_key}"
    bind_addr      = "0.0.0.0"
    advertise_addr = "{{ GetInterfaceIP \"ens3\" }}"
    client_addr    = "0.0.0.0"
    
    translate_wan_addrs = true
    alt_domain  = "${domain_name}"
    dns_config {
        enable_truncate = true
        udp_answer_limit = 100
    }
    recursors = ["62.138.222.111","62.138.222.222"]
    ca_file   = "/etc/consul/certificates/ca.pem"
    cert_file = "/etc/consul/certificates/cert.pem"
    key_file  = "/etc/consul/certificates/private_key.pem"
    verify_incoming = false
    verify_outgoing = false
    verify_server_hostname = true
    acl {
        enabled = false
        default_policy = "deny"
        enable_token_persistence = true
#       enable_token_replication = true
        down_policy = "extend-cache"
        tokens {
           master = "${master_token}"
        }
    }
#   primary_gateways = [ "<primary-mesh-gateway-ip>:<primary-mesh-gateway-port>"]
    connect {
      enabled = true
#     enable_mesh_gateway_wan_federation = true
    }
