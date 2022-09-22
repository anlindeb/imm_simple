# https://intersight.com/an/settings/api-keys/
## Generate API key to obtain the API Key and PEM file

variable "api_key" {
    description = "API Key for Intersight Account"
    type = string
    default = "61fdbccf7564612d3301c805/62c484937564612d3122983d/62c4b4147564612d31244144"
}

variable "secretkey" {
    description = "Filename (PEM) that provides secret key for Intersight API"
    type = string
    default = "SecretKey.txt"
}

variable "endpoint" {
    description = "Intersight API endpoint"
    type = string
    default = "https://intersight.com"
}

variable "organization" {
    type = string
    default = "default"
}

