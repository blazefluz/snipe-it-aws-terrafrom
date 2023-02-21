# output "vpc_id" {
#   value = aws_vpc.vpc.id
# }

# output "route53_zone_id" {
#   value = data.aws_route53_zone.route53-zone.id
# }

# output "security_group_ids" {
#   value = {
#     egress = aws_security_group.egress.id
#     http   = aws_security_group.http.id
#     ssh    = aws_security_group.ssh.id
#     mysql  = aws_security_group.mysql.id
#     nfs    = aws_security_group.nfs.id
#   }
# }

# output "acm_cert_arn" {
#   value = aws_acm_certificate.acm-cert.arn
# }

# output "efs_filesystem_id" {
#   value = aws_efs_file_system.efs-assets.id
# }

# output "efs_dns_name" {
#   value = "${aws_efs_file_system.efs-assets.id}.efs.${var.region}.amazonaws.com"
# }