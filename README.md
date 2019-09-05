# Fibs

## Why?

Ambassador ssie pałkę.

## Features

Fibs has 2 main features:

1. Mocking endpoints with any attributtes 
2. Executing shell commands locally on running machine.

## Usage 

### Mock request

If you would like to mock endpoint you need to hit `localhost:8080/mock` route, example cURL:
```bash
curl -v\
    -X POST\
    -H "Content-Type: application/json"\
    -H "Accept: application/json"\
    -d "{ \"headers\": { \"X-Custom-Header\" : \"X-Custom-Value\" }, \"method\": \"GET\", \"path\": \"/content/restaurant/([0-9]$)\", \"body\": { \"id\" : \"1\"} }"\
    "localhost:8080/mock"
```

where body represents endpoint details.
All possible attributes that can be mocked are listed below:


- `method` - HTTP request method, with possible values of: "GET", "POST", "PUT", "DELETE", "PATCH"
- `path` - endpoint path that supports regular expression, example: "/content/restaurant/([0-9]$)"
- `code` - HTTP response status code
- `body` - HTTP response, can be any value
- `headers` - HTTP response headers which is json 

### Execute Shell command