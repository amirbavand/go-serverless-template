package main

import (
	"context"
	"fmt"
	"go-template/utils"

	"github.com/aws/aws-lambda-go/lambda"
)

func HandleRequest(ctx context.Context, event interface{}) (string, error) {
	//initiate an instance of the struct
	MyEvent := utils.EventToImport{}
	MyEvent.Name = "World"
	fmt.Println("event", event)
	return fmt.Sprintf("Hello %s, this is the second function!", MyEvent.Name), nil
}

func main() {

	lambda.Start(HandleRequest)
}
