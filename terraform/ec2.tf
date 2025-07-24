resource "aws_instance" "c1_ec2" {
  ami                         = "ami-002db26d4a4c670c1"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.c1_public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.c1_sg.id]
  key_name                    = aws_key_pair.c1_ec2_key_pair.key_name
  user_data                   = file("user_data.sh")

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
    iops                  = 3000
    throughput            = 125
  }
}

resource "aws_key_pair" "c1_ec2_key_pair" {
  key_name   = "c1-ec2-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBM7QGShIeaNSkQgJCYJXzByOrlSm81f6PfGKikHcYe9GTB2fhiiClgzidsqb0FNTpSG3U4+Nd+QU4wR8J8n+sfUOTeDBZ5eySIoL2PWHREbJ4ezxmaK/VbTa6hOJ22AtfKH62hW81gPKMsrHh9nliNXv1RHg91X631HS08pD8xWi/qVRoLAOQIYD/doscKnz45onE+NGT4ZAbHhJhPePDAWk0hE9HMc/KjXgJGH5ocGh9jwA6G0GA6z7yLkNE6MRQlOXN9EDDr3BrIm6I4j1KhSrHuo+FVd2TCM1tdPr/P9ubsGwZbgOZlgSQHMXYq1fySRH9sGvz9Vt06fZzlwwj c1-ec2-key-pair\n"
}
