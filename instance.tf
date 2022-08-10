resource "aws_key_pair" "mykeypair" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1QZE4lJku8SqrI5ujELwM1bIZn3aDpeDUTE9oEsm+E3EF6wv/w6PP/mGZjKMpDZZsur7c4qpIZAfF41Oyu6IVNU7+JvEmugz5xe5vbU7654sFKICTk6BeArFjoCFamCcp9WFPY1rFCbRIS76fTmos6eXxhAft93Thy0IBFb5XMa6Nvog+BkvjrSPk2kgiffbmJO2plv2duKn5JfpAB2Keb8FW9z4CyECLVuhWg/KvpK7XuV/j/o/DGLZ/RYogKs8ZC0wQLwssYmBuanghWuAziY4UWW3PHMdwsN5l2Ka1q7UNxCBL9qIda78o11618MkA17sHVH18fiY/nFxHukmYXGbFkMDu38Kgjhi/1L6kpNcQNHFCzqw/pwvObR/RL9MgkYl/kYB9rAOz8mzwkvh8YEi4M0OxIEveEJvWxra+nj0IPmwYAW28EH/GzuHreY6p21AdwsJ5P4IRlI7KrFu1sZVBNsni5vn3Gw/hmO9fXX0ZTbPlkjBlOI4Li64qSds="
}
resource "aws_instance" "example" {
  ami           = lookup(var.AMIS, var.AWS_REGION)
  instance_type = "t2.micro"
  # the VPC subnet
  subnet_id = aws_subnet.main-public-1.id
  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow-ssh.id}"]
  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh"
    ]
  }
  connection {
    user        = var.INSTANCE_USERNAME
    private_key = file("${var.PATH_TO_PRIVATE_KEY}")
    host = self.public_ip
  }
}
