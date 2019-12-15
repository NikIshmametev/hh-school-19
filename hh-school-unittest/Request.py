import requests


class Request:

    BASE_API_URL = 'https://api.hh.ru/vacancies?text={}'

    def __init__(self, text):
        self.text = text
        self.api_url = self.BASE_API_URL.format(text)

    def get_response(self):
        return requests.get(self.api_url)
