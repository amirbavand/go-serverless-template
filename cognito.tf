resource "aws_cognito_user_pool" "my_pool" {
  name                     = "my_pool"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  deletion_protection = "INACTIVE"
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }


}
resource "aws_cognito_user_group" "admin_group" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.my_pool.id

  # Define IAM role for the admin group
}

resource "aws_cognito_user_group" "user_group" {
  name         = "user"
  user_pool_id = aws_cognito_user_pool.my_pool.id

  # Define IAM role for the user group
}

resource "aws_cognito_user_group" "producer_group" {
  name         = "producer"
  user_pool_id = aws_cognito_user_pool.my_pool.id

  # Define IAM role for the producer group
}
