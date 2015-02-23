#!/bin/bash

cd "id_service"
node id_service.js ../codeface.conf &
node_job=$!
cd ..

PYTHONPATH=~/.local/lib64/python2.7/site-packages/:$PWD ./codeface/runCli.py test -c codeface.conf
codeface_exit=$?
kill $node_job
exit $codeface_exit
