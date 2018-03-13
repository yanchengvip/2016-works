#!/usr/bin/python
# -*- coding: utf-8 -*-
import json
import requests
from fabric.api import env, local, run, parallel, cd, local

env.hosts = (
)

def deploy():
  local('npm run build')
  local('qrsync dist.json')
  local("scp -P 52345 dist/index.html root@m.jinhuobao.com.cn:/var/www/jht/")
