openapi: 3.0.3
info:
  title: My API
  version: 1.0.0
paths:
  /function1:
    post:
      x-amazon-apigateway-integration:
        uri: "arn:aws:apigateway:${region}:lambda:path/2015-03-31/functions/${function1_arn}/invocations"
        httpMethod: "POST"
        type: "aws_proxy"
        passthroughBehavior: "when_no_match"
        # ... other settings ...
      responses:
        '200':
          description: OK
  /function2:
    post:
      x-amazon-apigateway-integration:
        uri: "arn:aws:apigateway:${region}:lambda:path/2015-03-31/functions/${function2_arn}/invocations"
        httpMethod: "POST"
        type: "aws_proxy"
        passthroughBehavior: "when_no_match"
        # ... other settings ...
      responses:
        '200':
          description: OK
