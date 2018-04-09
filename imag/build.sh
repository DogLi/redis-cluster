#!/bin/bash
docker build -t 127.0.0.1:30001/ylf/redis:0.1 .
docker push 127.0.0.1:30001/ylf/redis:0.1
