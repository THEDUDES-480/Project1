data "aws_iam_policy" "admin" {
arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  }


resource "aws_iam_user" "Guest" {
  name = "Guest"
}

resource "aws_iam_access_key" "Guest" {
  user    = "${aws_iam_user.Guest.name}"
}


resource "aws_iam_user_policy_attachment" "attach" {
  user       = "${aws_iam_user.Guest.name}"
  policy_arn = "${data.aws_iam_policy.admin.arn}"
}

output "secret" {
  value = "${aws_iam_access_key.Guest.encrypted_secret}"
}