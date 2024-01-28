##########################
# Output value definitions
##########################

# Output the name of the S3 bucket used to store the Lambda function code
output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.lambda_bucket.id # Retrieves the ID of the S3 bucket resource
}

# Output the name of the deployed Lambda function
output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.hello_world_app.function_name # Retrieves the function name of the Lambda resource
}

# Output the base URL of the deployed API Gateway stage
output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url # Retrieves the invoke URL of the API Gateway stage
}
