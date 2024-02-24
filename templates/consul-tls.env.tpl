export CONSUL_HTTP_ADDR=${consul_ip}:8501
export CONSUL_CACERT=/etc/consul/certificates/ca.pem
export CONSUL_CLIENT_CERT=/etc/consul/certificates/cert.pem
export CONSUL_CLIENT_KEY=/etc/consul/certificates/private_key.pem
export CONSUL_HTTP_SSL_VERIFY=false
export CONSUL_HTTP_SSL=true
export CONSUL_HTTP_TOKEN=
