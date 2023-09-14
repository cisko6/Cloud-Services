availability_zone = "eu-central-1a"
vpc_network = "10.0.0.0/16"
public_sn_IP = "10.0.1.0/24"
private_sn_IP = "10.0.2.0/24"
default_route = ["0.0.0.0/0", "::/0"]
instances = [{ami = "ami-04e601abe3e1a910f", instance_type = "t2.micro", key_name = "key_test"},
             {ami = "ami-04e601abe3e1a910f", instance_type = "t2.micro", key_name = "key_test"}]

