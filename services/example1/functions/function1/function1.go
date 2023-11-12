package main

import (
	"context"
	"fmt"
	"go-template/services/example1/example1Utils"

	"github.com/aws/aws-lambda-go/lambda"
)

type Response struct {
	StatusCode int               `json:"statusCode"`
	Headers    map[string]string `json:"headers"`
	Body       string            `json:"body"`
}

func HandleRequest(ctx context.Context, event interface{}) (Response, error) {

	//create instance of EventToImport11
	eventToImport11 := example1Utils.EventToImport11{}
	eventToImport11.Name = "World"
	fmt.Println("eventToImport11", eventToImport11)

	fmt.Println("event", event)
	//define a response object
	response := Response{}
	response.StatusCode = 200
	response.Headers = map[string]string{
		"Content-Type": "application/json",
	}
	response.Body = "{\"message\": \"Hello World\"}"
	return response, nil
}

func main() {
	lambda.Start(HandleRequest)
}
