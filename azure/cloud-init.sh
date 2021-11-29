#!/bin/sh
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo apt-get install git
git clone "https://github.com/dockersamples/node-bulletin-board.git"
