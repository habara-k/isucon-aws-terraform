resource "aws_key_pair" "participant-key" {
  key_name   = "isucon_key"
  public_key = file("./modules/credential/isucon_id_ed25519.pub")
}

locals {
  bench_index = length(var.ec2_members) - 1
}

resource "aws_instance" "participant-instance" {
  ami                         = data.aws_ami.standalone_ami.id
  count                       = length(var.ec2_members)
  instance_type               = count.index == local.bench_index && var.ec2_bench_instance_type != "" ? var.ec2_bench_instance_type : var.ec2_instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.participant-key.id
  security_groups             = [var.security_group_id]

  root_block_device {
    volume_type           = var.ec2_volume_type
    volume_size           = var.ec2_volume_size
    delete_on_termination = true
  }

  tags = {
    Name = format("isucon-%s", lookup(var.ec2_members, count.index))
  }
}
