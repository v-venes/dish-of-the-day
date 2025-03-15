provider "aws" {
  region = "us-east-1"
}

module "recipes_lambda" {
  source        = "./modules/lambda"
  function_name = "GetRecipe"
  handler       = "bootstrap"
  filename      = "../apps/get-recipe/function.zip"
  runtime       = "provided.al2"
}

resource "aws_api_gateway_rest_api" "recipes_api" {
  name = "RecipesAPI"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.recipes_api.id
  parent_id   = aws_api_gateway_rest_api.recipes_api.root_resource_id
  path_part   = "recipes"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id      = aws_api_gateway_rest_api.recipes_api.id
  resource_id      = aws_api_gateway_resource.resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false // TODO: Arrumar
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.recipes_api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.recipes_lambda.invoke_arn

  depends_on = [aws_api_gateway_method.method]
}

resource "aws_api_gateway_method_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.recipes_api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"

  //cors section
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

}

resource "aws_api_gateway_integration_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.recipes_api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = aws_api_gateway_method_response.proxy.status_code


  //cors
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method.method,
    aws_api_gateway_integration.integration
  ]
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.recipes_api.id

  depends_on = [
    aws_api_gateway_method.method,
    aws_api_gateway_integration.integration
  ]
}

resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.recipes_api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "RecipesUsagePlan"

  throttle_settings {
    rate_limit  = 5  # 10 requisições por segundo
    burst_limit = 10 # 20 requisições em um curto período
  }

  api_stages {
    api_id = aws_api_gateway_rest_api.recipes_api.id
    stage  = aws_api_gateway_stage.prod.stage_name
  }
}

resource "aws_api_gateway_api_key" "recipes_api_key" {
  name = "RecipesAPIKey"
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.recipes_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.recipes_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.recipes_api.execution_arn}/*/*"
}

resource "aws_dynamodb_table" "recipes" {
  name         = "Recipes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
