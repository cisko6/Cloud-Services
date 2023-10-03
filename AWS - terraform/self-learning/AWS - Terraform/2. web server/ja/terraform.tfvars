#subnet_IP = "10.0.1.0/24"
#subnet_IP = ["10.0.1.0/24", "10.0.2.0/24"]
subnet_IP = [{cidr_block = "10.0.1.0/24",
              Name = "test-subnet"}]

instance_ubuntu = [{ami = "ami-04e601abe3e1a910f",
                    instance_type = "t2.micro",
                    key_name = "my_test_key"}]

default_route = ["0.0.0.0/0", "::/0"]
private_instance_IP = "10.0.1.50"
availability_zone = "eu-central-1a"
