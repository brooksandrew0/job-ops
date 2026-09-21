import json,secrets,urllib.request,urllib.error
base='http://127.0.0.1:3001'
def request(path, method='GET', data=None, token=None):
 headers={'Content-Type':'application/json'}
 if token: headers['Authorization']='Bearer '+token
 req=urllib.request.Request(base+path,method=method,headers=headers,data=json.dumps(data).encode() if data is not None else None)
 try:
  with urllib.request.urlopen(req,timeout=30) as r: return r.status,json.load(r)
 except urllib.error.HTTPError as e: return e.code,None
assert request('/health')[0]==200
status,body=request('/api/auth/bootstrap-status')
assert status==200 and body['data']['setupRequired']
password=secrets.token_urlsafe(32)
status,body=request('/api/auth/setup','POST',{'username':'securitytest','password':password})
assert status==201
status,body=request('/api/auth/login','POST',{'username':'securitytest','password':password})
assert status==200
token=body['data']['token']
for endpoint in ['/api/auth/me','/api/settings','/api/jobs']:
 assert request(endpoint,token=token)[0]==200,endpoint
assert request('/api/settings')[0]==401
assert request('/api/auth/login','POST',{'username':'securitytest','password':'incorrect-test-password'})[0]==401
assert request('/api/auth/setup','POST',{'username':'second-user','password':password})[0]==400
print('PASS health, migrations, initial setup, login, private settings/jobs access, unauthorized rejection, duplicate setup rejection')
