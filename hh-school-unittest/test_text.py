import unittest
from Request import Request


class TestTextField(unittest.TestCase):

    def test_positive_status(self):
        request = Request('продажа торгового оборудования')
        self.assertEqual(request.get_response().status_code, 200)

    def test_positive_match(self):
        request = Request('NAME:!(продажа торгового оборудования)')
        items = request.get_response().json()['items']
        bools = ['продажа торгового оборудования' in item['name'].lower() for item in items]
        self.assertEqual(all(bools), True)

    def test_positive_bool_OR(self):
        request = Request('NAME:(!продажи OR !sales)')
        items = request.get_response().json()['items']
        bools = [('продажи' in item['name'].lower() or 'sales' in item['name'].lower()) for item in items]
        self.assertEqual(all(bools), True)

    def test_positive_empty(self):
        # Если запрос пустой, то список вакансий должен быть непустым
        request = Request('')
        self.assertNotEqual(len(request.get_response().json()['items']), 0)

    def test_negative_boundary(self):
        # Проверка граничного перехода ответа http запроса
        request = Request('0' * 2 ** 14)
        self.assertEqual(request.get_response().status_code, 200)
        request = Request('0' * 2 ** 15)
        self.assertEqual(request.get_response().status_code, 502)

    def test_negative_long_uri(self):
        # Проверка кода ответа при слишком длинном uri
        request = Request('0' * 2 ** 16)
        self.assertEqual(request.get_response().status_code, 414)
