# Fibs

## Why?

Have you ever tried to mock web server in Xcode UI Tests?
Fibs is the simplest way to do this - completely separated from Xcode project. 
It is a server running locally that serves endpoint that allows you mocking other endpoints!

## Features

Fibs has 2 main features:

1. Mocking endpoints with any attributtes 
2. Executing shell commands locally on running machine

## Usage 

Run the application before starting UI tests with `./Pods/Fibs/fibs` 
<!---
or `fibs` if you installed via brew
--->

### Mock request

If you would like to mock endpoint you need to hit `localhost:8080/mock` route (from UITest target), example cURL:
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
- `delay` - time interval in miliseconds that (integer) that response will be delayed

### Execute Shell command

Fibs gives you also ability to run any shell command on macOS from UI test target. 
This could be useful for running special mocking scripts that modifies your tested system.
To run shell command hit `localhost:8080/command`, example cURL: 
```bash
curl -v\
    -X POST\
    -H "Content-Type: application/json"\
    -H "Accept: application/json"\
    -d "{ \"command\": \"echo 'Hello World'\"}"\
    "localhost:8080/command"
```
Parameters of such call are:
- `command` - raw string command that you want to run on hosting system

Also, response for this request is synchronous, which means you can later process it back in UITests target. 
For the request above, the response would be:
```bash
{"raw_response":"Hello World"}
```

## Instalation

### Cocoapods

```
pod 'Fibs'
```

### Brew

TODO
