
**The Terraform script in this repo deploys several resources within AWS, structured for a serverless application with monitoring and alerting capabilities. Here's a breakdown of the resources and their purposes:**

* **Random Pet Resource**: Generates a random name for an S3 bucket, used to uniquely name the bucket.

* **AWS S3 Bucket**: Creates an S3 bucket with the randomly generated name. This bucket is used for storing the Lambda function's code.

* **S3 Bucket Ownership Controls**:Sets ownership controls for the S3 bucket, specifying the object ownership preference (e.g., BucketOwnerPreferred).

* **S3 Bucket ACL**: Applies an Access Control List to the S3 bucket, setting it to private to restrict access.

* **Archive File Data Source**: Creates a zip archive of the Lambda function code, preparing it for upload to the S3 bucket.

* **AWS S3 Object**: Uploads the zipped Lambda function code to the S3 bucket. 

* **AWS Lambda Function**: Creates the AWS Lambda function, using the uploaded code in the S3 bucket. The function uses Python 3.9 as its runtime.

* **CloudWatch Log Group for Lambda**: Creates a CloudWatch Log Group specifically for the Lambda function, enabling logging of the function's executions.

* **IAM Role for Lambda**: Defines an IAM role for the Lambda function, allowing it to assume necessary permissions for execution.

* **IAM Role Policy Attachment**: Attaches a basic execution role policy to the Lambda IAM role, granting necessary permissions for Lambda execution.

* **AWS API Gateway**: Sets up an HTTP API Gateway as a front-end to trigger the Lambda function.

* **API Gateway Stage**: Creates a stage for the API Gateway with auto-deploy enabled.

* **API Gateway Access Logging**: Configures access logging for the API Gateway stage, specifying the log format and destination.

* **API Gateway Integration**: Creates an integration between the API Gateway and the Lambda function, allowing the API to trigger the Lambda.

* **API Gateway Route**: Defines a route in the API Gateway to direct incoming requests to the Lambda integration.

* **CloudWatch Log Group for API Gateway**: Creates a separate CloudWatch Log Group for the API Gateway, enabling logging of access and errors.

* **Lambda Permission for API Gateway**: Grants the API Gateway permission to invoke the Lambda function.

* **SNS Topic and Subscription for CloudWatch Alerting**: Creates an SNS topic for alarm notifications and subscribes an email endpoint to it.

* **CloudWatch Metric Alarm**: Sets up a CloudWatch Metric Alarm to monitor Lambda errors, triggering an alert to the SNS topic if an error condition is met.

**This script effectively creates a serverless application architecture with an AWS Lambda function, an S3 bucket for code storage, API Gateway for invocation, and CloudWatch for logging and monitoring. Additionally, it implements an alerting mechanism using SNS and CloudWatch Alarms.**

```
To reproduce the task, you will need the following prerequisites:

1. AWS account, a Access Key and Secret Access Key.
2. Terraform Cloud account. (Free and awesome). (https://developer.hashicorp.com/terraform/tutorials/cloud-get-started)

NOTE: For a quick test, you can clone the repo and run it from your local machine.

