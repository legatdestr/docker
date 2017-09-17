#!/usr/bin/env bash


docker build -t em_ksb_frontend `pwd` --build-arg http_proxy=${http_proxy} --build-arg https_proxy=${http_proxy}
