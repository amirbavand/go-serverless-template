package main

import (
	"context"
	"fmt"
	"go-template/services/example1/example1Utils"

	"github.com/aws/aws-lambda-go/lambda"
)

func HandleRequest(ctx context.Context, event interface{}) (string, error) {

	//create instance of EventToImport11
	eventToImport11 := example1Utils.EventToImport11{}
	eventToImport11.Name = "World"
	fmt.Println("eventToImport11", eventToImport11)

	fmt.Println("event", event)

	return "Hello world3", nil
}

func main() {
	lambda.Start(HandleRequest)
}
