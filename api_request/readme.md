# API Interaction Script

## Requirements
  Python 3.7
  Pipenv

# Libraries
  requests
  fire

## Installation
  `pipenv install && pipenv shell`

## Usage
  I wrote the script as a command line tool. For your convenience, I have prepared 3 pre-written commands:
  * Get the 200 most recent TODOs: `python3 ./api_interaction.py get`
    As a note: API does not have a date field, so I used id desc order for pagination to get the most recent todos
  * Create a TODO (using mocked data defined in code): `python3 ./api_interaction.py post`
  * Delete a TODO given an ID: `python3 ./api_interaction.py delete 1234`

  Or you can define your own parameter:
  GET (id desc order): `python3 ./api_interaction.py send_request --method=get --limit=5 --page=1`
  POST: `python3 ./api_interaction.py send_request --method=post`
  DELETE: `python3 ./api_interaction.py send_request --method=delete --id=1234`
