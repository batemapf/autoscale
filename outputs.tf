output "dns" {
  value = "${aws_instance.web.dns}"
}

output "ip" {
  value = "${aws_instance.web.ip}"
}
