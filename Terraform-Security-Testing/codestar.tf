resource "aws_codestarconnections_host" "codestar_host" {
  name              = "terraform-respo-host"
  provider_endpoint = var.codestar_provider_endpoint
  provider_type     = var.codestar_provider_type
}

resource "aws_codestarconnections_connection" "codestar_connection" {
  name          = "terraform-respo-connection"
  host_arn = aws_codestarconnections_host.codestar_host.arn
}