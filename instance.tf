data "template_file" "init_update_machine" {
  template = "${file("templates/init_update_machine.tpl")}"
 }

resource "aws_instance" "machine" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.sg_instance.id}"]
  associate_public_ip_address = true
  subnet_id            = "${aws_subnet.public_a.id}"
  key_name             = "${aws_key_pair.ssh.key_name}"
  user_data = "${data.template_file.init_update_machine.rendered}"

tags {
    Name    = "${var.project_name}-machine"
    project = "${var.project_name}"
  }
}
