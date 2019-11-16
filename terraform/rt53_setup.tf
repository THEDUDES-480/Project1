//route 53 hosted zone
resource "aws_route53_zone" "rt_53" {
  name = "thedudes.space"
}

//create elb
resource "aws_elb" "elb" {
  name               = "Project1ELB"
  subnets = ["${aws_subnet.pub_2.id}", "${aws_subnet.pub_1.id}"]
  
  
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }
  
  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-west-2:538099035665:certificate/d4d96007-f5f6-4c5d-b578-d9d37f8cfdf6"
  }

  instances                   = ["${aws_instance.test-ec2-instance.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 60

  tags = {
    Name = "CIT480_Project_1_ELB"
  }
  security_groups =  ["${aws_security_group.default.id}" ]
}

//add router to allias
resource "aws_route53_record" "rt_53_elb_alias" {
  zone_id = "${aws_route53_zone.rt_53.zone_id}"
  name    = "thedudes.space"
  type    = "A"

  alias {
    name                   = "${aws_elb.elb.dns_name}"
    zone_id                = "${aws_elb.elb.zone_id}"
    evaluate_target_health = false
  } 
}
  
//add www alias
resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.rt_53.zone_id}"
  name    = "www.thedudes.space"
  type    = "A"

  alias {
    name                   = "${aws_elb.elb.dns_name}"
    zone_id                = "${aws_elb.elb.zone_id}"
    evaluate_target_health = false
  }
}




