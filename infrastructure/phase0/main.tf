#
# DynamoDB tables
#
resource "aws_dynamodb_table" "Pingpong" {
  name           = "Pingpong"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ServiceName"

  attribute {
    name = "ServiceName"
    type = "S"
  }
}
