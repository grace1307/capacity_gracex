import logging
import json
import requests
import fire
from requests.exceptions import HTTPError

logger = logging.getLogger(__name__)


class SendRequest:
    def send_request(self, **kwargs):
        url = 'http://jsonplaceholder.typicode.com/todos'

        try:
            method = kwargs.get('method')

            if method is None or method.upper() not in ['GET', 'POST', 'DELETE']:
                raise Exception('Method missing, only GET, POST, DELETE methods are allowed')

            method = method.upper()
            response = None

            if method == 'GET':
                page = kwargs.get('page', 1)
                limit = kwargs.get('limit', 200)

                if not isinstance(page, int) \
                        or not isinstance(limit, int) \
                        or page <= 0 \
                        or limit <= 0:
                    raise Exception('Bad input type, both page and limit should be positive int')

                # API does not have a date field, so I used id desc order for pagination
                response = requests.get(url, params={
                    '_page': page,
                    '_limit': limit,
                    '_sort': 'id',
                    '_order': 'desc'
                })

            elif method == 'DELETE':
                todo_id = kwargs.get('id')

                if todo_id is None \
                        or not isinstance(todo_id, int) \
                        or todo_id <= 0:
                    raise Exception('Bad input type, id should be positive int')
                response = requests.delete(f"{url}/{todo_id}")

            elif method == 'POST':
                mock_data = {
                    'userId': 1,
                    'title': 'New todo',
                    'completed': False
                }
                response = requests.post(url, mock_data)

            # Post-send checks
            if not response or response.status_code not in [200, 201]:
                raise Exception(f'Bad response returned from API: {response or response.status_code}')

            response_json = response.json()  # dictionary
            formatted_json_string = json.dumps(response_json, indent=4, sort_keys=True)  # string

            # Not really a warning, just for console printing
            logger.warning('Request sent, operation successful. Response:')

            print(formatted_json_string)  # Print result
        except HTTPError as http_err:
            logger.error(f'HTTP error: {http_err}')
        except Exception as e:
            logger.error(f'Failed to execute request: {str(e)}')

    def get(self):
        self.send_request(method='GET', limit=200, page=1)

    def post(self):
        self.send_request(method='POST')

    def delete(self, id):
        self.send_request(method='DELETE', id=id)


if __name__ == '__main__':
    fire.Fire(SendRequest)

# Code formatted with autopep8 by PyCharm
