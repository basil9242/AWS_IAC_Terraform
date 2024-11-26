output "codestar_arn" {
    value = aws_codestarconnections_connection.codestar_connection.arn
    description = "CodeStar ARN"
}

