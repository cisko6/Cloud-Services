username   = "stud4"
password   = "onpk"
#key_name   = "test_pcBeast"
key_name   = "test-ntbk"
create_key = false

bastion_userdata  = "bastion_userdata.sh"
minikube_userdata = "minikube_userdata.sh"

tenant_name = "ONPK_4"
auth_url    = "https://158.193.152.44:5000/v3/"

#CIDR_pool = ["192.168.10.0/24", "10.0.10.0/24"]

instance_settings = [{ name = "minikube-instance", image_name = "ubuntu-22.04-kis", flavor_name = "2c2r20d" },
                     { name = "bastion-instance",  image_name = "ubuntu-22.04-kis", flavor_name = "1c05r8d" }]
