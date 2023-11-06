
resource "aws_cognito_user_pool_client" "pool_client" {
  name = "project-x"
  user_pool_id = aws_cognito_user_pool.pool.id

  callback_urls                        = ["https://google.com"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
}
output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.pool_client.id
}

resource "aws_cognito_user_pool_domain" "pool_domain" {
  domain       = "es-project-x"
  user_pool_id = aws_cognito_user_pool.pool.id
}
output "user_pool_domain_id" {
  value = aws_cognito_user_pool_domain.pool_domain.id
}

resource "aws_cognito_user_pool" "pool" {

  /** Basic Configuation */
  name                = "user-pool"
  username_attributes = ["email"]
  auto_verified_attributes = ["email"]

  username_configuration {
    case_sensitive = false
  }


  /** Required Standard Attributes*/
  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "email"
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "given_name"
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "family_name"
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

}
output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}
