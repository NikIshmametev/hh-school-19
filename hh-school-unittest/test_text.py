import unittest
from Request import Request


class TestTextField(unittest.TestCase):

    def test_positive_status(self):
        response = Request('продажа торгового оборудования').get_response()
        self.assertEqual(response.status_code, 200)

    def test_positive_match(self):
        response = Request('NAME:!(продажа торгового оборудования)').get_response()
        items = response.json()['items']
        bools = ['продажа торгового оборудования' in item['name'].lower() for item in items]
        self.assertEqual(all(bools), True)

    def test_positive_OR(self):
        response = Request('NAME:(!продажи OR !sales)').get_response()
        items = response.json()['items']
        bools = [('продажи' in item['name'].lower() or 'sales' in item['name'].lower()) for item in items]
        self.assertEqual(all(bools), True)

    def test_positive_empty(self):
        # Если запрос пустой, то список вакансий должен быть непустым
        response = Request('').get_response()
        self.assertNotEqual(len(response.json()['items']), 0)

    def test_positive_decoding(self):
        # При подстановке кодированного символа и некодированного ожидаем одинаковую выдачу
        response1 = Request('NAME:1').get_response()
        response2 = Request('NAME%3A%31').get_response()
        self.assertEqual(response1.json(), response2.json())


    def test_negative_boundary(self):
        # Проверка граничного перехода ответа http запроса
        response = Request('0' * 2 ** 14).get_response()
        self.assertEqual(response.status_code, 200)
        response = Request('0' * 2 ** 15).get_response()
        self.assertEqual(response.status_code, 502)

    def test_negative_long_uri(self):
        # Проверка кода ответа при слишком длинном uri
        response = Request('0' * 2 ** 16).get_response()
        self.assertEqual(response.status_code, 414)

    def test_negative_spec_symbols(self):
        # Проверим выполнение запроса с различными спецсимволами
        response = Request(r'@/\\#%$*^~?').get_response()
        self.assertEqual(response.status_code, 200)

    def test_negative_logical_without_params(self):
        response = Request(r'AND').get_response()
        self.assertEqual(response.status_code, 200)

    def test_negative_another_field(self):
        # Если в качестве поле текст подставить другое поле
        length = 100
        response = Request(r'&per_page=%d' % length).get_response()
        self.assertEqual(len(response.json()['items']), length)

    def test_sql_injection_quote(self):
        # Попробуем закомментировать остальную часть запроса
        response = Request("'").get_response()
        self.assertEqual(response.status_code, 200)

    def test_sql_injection_expression(self):
        # Попробуем сделать SQL-запрос невалидным, передав неверное условие
        response = Request('OR 1=2').get_response()
        self.assertEqual(response.status_code, 200)

