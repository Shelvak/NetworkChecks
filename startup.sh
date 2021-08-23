#!/bin/bash -i

source $HOME/.bashrc

cd $(dirname $(readlink -f "$0"))
bundle exec rackup -o 0.0.0.0  >> server.log 2>&1
