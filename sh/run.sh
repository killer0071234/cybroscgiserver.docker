#!/bin/bash
# @Author: Daniel Gangl
# @Date:   2021-07-11 22:45:20
# @Last Modified by:   Daniel Gangl
# @Last Modified time: 2021-07-11 23:01:01
set -e
echo "Starting nginx server..."
nginx
cd /usr/local/bin/scgi_server/src
echo "Starting cybroscgiserver..."
python app.py
RETVAL=$?
exit $RETVAL