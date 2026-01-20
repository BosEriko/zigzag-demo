# README

## ENV
It's not advisable to do this but for demo purposes you can create the env like so:
```sh
echo "WEATHERSTACK_KEY=2ec80b99b98559693086a95f1563b92d" >> .env
```

## Run the App
This is an example weather app for ZigZag. To run you must have ruby and rails installed on your machine.
```sh
bundle install
rails s
```

## URL
You can check it out here:
```sh
http://localhost:8080/v1/weather?city=melbourne&country=AU
```