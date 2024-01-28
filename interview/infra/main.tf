# Configure the AWS Provider
provider "aws" {
  region = var.aws_region # Set the AWS region from a variable

# Default tags to be applied to all resources
  default_tags {
    tags = {
      HB-interview = "lambda-api-gateway" # A tag applied to all resources
    }
  }

}

# Generate a random name for the S3 bucket
resource "random_pet" "lambda_bucket_name" {
  prefix = "hb-loves" # Prefix for the generated name
  length = 4          # Number of words in the generated name
}

# Create an S3 bucket with the generated random name
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id # Name of the bucket
}

# Set ownership controls for the S3 bucket
resource "aws_s3_bucket_ownership_controls" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id     # Referencing the created S3 bucket
  rule {
    object_ownership = "BucketOwnerPreferred" # Set object ownership preference
  }
}

# Set the Access Control List (ACL) for the S3 bucket
resource "aws_s3_bucket_acl" "lambda_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.lambda_bucket]

  bucket = aws_s3_bucket.lambda_bucket.id # S3 bucket to apply the ACL to
  acl    = "private" # Set the bucket to be private
}

# Define a data source to create a zip archive of the Lambda function
data "archive_file" "lambda_hello_world_app" {
  type = "zip"

  source_dir  = "${path.module}/hello-world-app" # Directory containing Lambda code
  output_path = "${path.module}/hello-world-app.zip" # Output path for the zip file
}

# Upload the zipped Lambda function code to the S3 bucket
resource "aws_s3_object" "lambda_hello_world_app" {
  bucket = aws_s3_bucket.lambda_bucket.id # S3 bucket to upload to

  key    = "hello-world-app.zip" # Key for the uploaded object
  source = data.archive_file.lambda_hello_world_app.output_path # Source file

  etag = filemd5(data.archive_file.lambda_hello_world_app.output_path) # ETag for versioning
}

# Create the AWS Lambda function
resource "aws_lambda_function" "hello_world_app" {
  function_name = "hello-world-app" # Name of the Lambda function

  s3_bucket = aws_s3_bucket.lambda_bucket.id # S3 bucket containing the code
  s3_key    = aws_s3_object.lambda_hello_world_app.key # Object key in S3 bucket

  runtime = "python3.9" # Runtime for the Lambda function
  handler = "hello-world-app.handler" # Handler function in the Lambda code

  source_code_hash = data.archive_file.lambda_hello_world_app.output_base64sha256 # Hash for code changes

  role = aws_iam_role.lambda_exec.arn # IAM role for Lambda execution
}

# Create a CloudWatch Log Group for the Lambda function
resource "aws_cloudwatch_log_group" "hello_world_app" {
  name = "/aws/lambda/${aws_lambda_function.hello_world_app.function_name}" # Log group name pattern

  retention_in_days = 30 # Log retention period
}

# Define an IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda" # Name of the IAM role

# IAM policy that allows Lambda to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

# Attach the basic execution role policy to the Lambda IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name # The IAM role to attach the policy to
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" # ARN of the policy
}

####################
# Create API GATEWAY
####################

resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw" # Name of the API Gateway
  protocol_type = "HTTP" # Protocol type
}

# Create a stage for the API Gateway
resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id # Reference to the created API Gateway

  name        = "serverless_lambda_stage" # Name of the stage
  auto_deploy = true # Enable auto-deploy to update the stage automatically when changes are made

# Configure access logging for the stage
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn # CloudWatch log group ARN for logging

# Define the format of the access logs
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

# Create an integration to connect the API Gateway to the Lambda function
resource "aws_apigatewayv2_integration" "hello_world_app" {
  api_id = aws_apigatewayv2_api.lambda.id # Reference to the created API Gateway

  integration_uri    = aws_lambda_function.hello_world_app.invoke_arn # ARN of the Lambda function to integrate
  integration_type   = "AWS_PROXY" # Integration type (AWS_PROXY for Lambda proxy integration)
  integration_method = "POST" # HTTP method for the integration (POST in this case)
}

# Define a route for the API Gateway
resource "aws_apigatewayv2_route" "hello_world_app" {
  api_id = aws_apigatewayv2_api.lambda.id # Reference to the created API Gateway

  route_key = "GET /" # Define the route key (HTTP method and path)
  target    = "integrations/${aws_apigatewayv2_integration.hello_world_app.id}" # Target integration for this route
}

# Create a CloudWatch Log Group for API Gateway access logging
resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}" # Name of the log group

  retention_in_days = 30 # Log retention period
}

# Grant API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway" # Identifier for the policy statement
  action        = "lambda:InvokeFunction" # Action to allow (invoke the function)
  function_name = aws_lambda_function.hello_world_app.function_name # Name of the Lambda function
  principal     = "apigateway.amazonaws.com" # Principal that is granted permission

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*" # ARN of the API Gateway to allow invocation from
}
