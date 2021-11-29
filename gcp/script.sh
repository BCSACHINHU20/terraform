#!/bin/bash
sudo apt-get install nginx
sudo systemctl enable nginx
sudo systemctl restart nginx
curl http://localhost:80
