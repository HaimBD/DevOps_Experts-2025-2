module "s3" {
  source = "./modules/s3"
}

module "sqs" {
  source = "./modules/sqs"
}

module "lambda" {
  source      = "./modules/lambda"
  bucket_name = module.s3.bucket_name
  queue_url   = module.sqs.queue_url
}

module "rds" {
  source = "./modules/rds"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "helm_app" {
  source = "./modules/helm_app"

  db_host          = module.rds.rds_endpoint
  db_user          = module.rds.db_username
  db_password      = module.rds.db_password
  dynamodb_table   = module.dynamodb.dynamodb_table_name

  depends_on = [module.lambda, module.rds, module.dynamodb]
}