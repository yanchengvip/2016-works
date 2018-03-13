#!/usr/bin/env python3
# encoding: utf-8
import gevent.monkey;gevent.monkey.patch_all()
import requests
import bottle
import logging
from json import dumps
from bottle import get, post, run, request, response
from tornado.log import enable_pretty_logging

class EnableCors(object):
    name = 'enable_cors'
    api = 2

    def apply(self, fn, context):
        def _enable_cors(*args, **kwargs):
            # set CORS headers
            response.headers['Access-Control-Allow-Origin'] = '*'
            response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, OPTIONS'
            response.headers['Access-Control-Allow-Headers'] = 'Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token'
            response.headers['Content-Type'] = 'application/json'

            if bottle.request.method != 'OPTIONS':
                # actual request; reply with the actual response
                return fn(*args, **kwargs)

        return _enable_cors


app = bottle.app()
app.install(EnableCors())

res = requests.Session()

@get('/<path:re:.*>')
def handler(path):
  # token = request.query.remember_token
  # data = res.get('http://rails.tunnel.jinhuobao.com.cn/'+path, params=dict(request.query))
  # print(data.content)
  # return data.content
  print(dict(request.query))
  return '{"status": "ok"}'


if __name__ == '__main__':
#   enable_pretty_logging()
#   logger = logging.getLogger()
#   logger.setLevel(logging.DEBUG)
#   print("""Server starting up (using GeventServer())...
# Listening on http://0.0.0.0:8088/
# Hit Ctrl-C to quit.\n""")
  app.run(port=8088, host='0.0.0.0', server="gevent", reloader=True, debug=True, quiet=False)
