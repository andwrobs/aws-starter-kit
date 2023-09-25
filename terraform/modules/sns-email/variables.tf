################################################################################################################################
# services/_template/variables.tf
#
# This is a template for a service module's variables configuration file. 
# The values specified here are used by resource blocks in main.tf
################################################################################################################################

variable "sns_protocol" {
  type    = string
  default = "email"
  # default = "email-json"
}

# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# do not update below this flag, these variables are set as input variables by root module
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
variable "sns_emails" {
  type = list(string)
}
variable "environment_name" {
  type = string
}
variable "service_name" {
  type = string
}
variable "project_name" {
  type = string
}
