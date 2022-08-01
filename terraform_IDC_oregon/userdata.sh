#!/bin/bash

sudo yum install -y openswan
echo "net.ipv4.ip_forward = 1" >> temp
echo "net.ipv4.conf.default.rp_filter = 0" >> temp
echo "net.ipv4.conf.default.accept_source_route = 0" >> temp
sysctl -p