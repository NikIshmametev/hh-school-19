from Request import Request

request = Request('NAME:(!продажи or !sales)')
response = request.get_response()#.json()

a = []
for item in response.json()['items']:
    a.append('продажи' in item['name'].lower() or 'sales' in item['name'].lower())
print(response.status_code)