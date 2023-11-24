/* Issued by AWS Certificate Manager (ACM) */
variable "cert_arn" {
  type = string
  default = "arn:aws:acm:eu-west-1:558216347146:certificate/c7786ee5-9756-4ade-bc87-0096306765ac" # *.project-x.pt
}

/* Web UI Domain */
variable "web_ui_domain" {
  type = string
  default = "https://web.project-x.pt"
}