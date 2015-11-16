#!/bin/bash

curl -ks http://bootstrap.saltstack.com/stable/bootstrap-salt.sh | sh
yum install salt-master
systemctl start salt-master
