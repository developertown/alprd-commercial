#!/usr/bin/env bash


docker build -t developertown/alprd-commercial:latest . \
  && docker push developertown/alprd-commercial:latest
