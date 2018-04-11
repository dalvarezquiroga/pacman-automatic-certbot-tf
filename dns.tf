resource "aws_route53_zone" "external" {
  name = "demo.yourdomain.com."
}

resource "aws_route53_record" "dns_machine" {
  zone_id = "${aws_route53_zone.external.zone_id}"
  name    = "demo.yourdomain.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.machine.public_ip}"]
}
