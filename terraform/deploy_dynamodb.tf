
resource "aws_dynamodb_table" "tabelaDynamo" {
  name           = "aggTwitter"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "usuario"

  

  attribute {
    name = "usuario"
    type = "S"
  }

  

}
