package main

import (
	"context"
	"fmt"
	"go-template/utils"

	"github.com/aws/aws-lambda-go/lambda"
)

type Response struct {
	StatusCode int               `json:"statusCode"`
	Headers    map[string]string `json:"headers"`
	Body       string            `json:"body"`
}

func HandleRequest(ctx context.Context, event interface{}) (Response, error) {
	//initiate an instance of the struct
	MyEvent := utils.EventToImport{}
	MyEvent.Name = "World"
	fmt.Println("event", event)
	//define a response object
	response := Response{}
	response.StatusCode = 200
	response.Headers = map[string]string{
		"Content-Type": "application/json",
	}
	response.Body = "{\"message\": \"This is second function\"}"
	return response, nil
}

func main() {

	lambda.Start(HandleRequest)
}
