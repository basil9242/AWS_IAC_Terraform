variable "codestar_provider_endpoint" {
    description = "Codestar provider endpoint(Respo url)"
    type = string
    default = ""
}

variable "codestar_provider_type" {
    description = "Codestar provider type. Valid values are Bitbucket, GitHub, GitHubEnterpriseServer, GitLab or GitLabSelfManaged"
    type = string
    default = ""
}

variable "terraform_script_path" {
    description = "Terraform script path"
    type = string
    default = ""
}

variable "repository_name" {
    description = "Repository name"
    type = string
    default = ""
}

variable "branch_name" {
    description = "Branch name"
    type = string
    default = ""
}