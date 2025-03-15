output "lambda_function_name" {
  value = module.recipes_lambda.function_name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.recipes.name
}

output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}/recipes"
}

output "api_key" {
  value     = aws_api_gateway_api_key.recipes_api_key.value
  sensitive = true
}
