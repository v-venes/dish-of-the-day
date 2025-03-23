package main

import (
	"context"
	"github.com/aws/aws-lambda-go/lambda"
)

func handler(ctx context.Context) (string, error) {
	// gerar id aleatório

	// bater no dynamo pra ver se existe

	// se existir retorna

	// se n existir passar para o openai

	// salvar o retorno no dynamo

	// retornar
	return "Hello, World!", nil
}

func main() {
	lambda.Start(handler)
}
