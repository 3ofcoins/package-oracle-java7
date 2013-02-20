#!/bin/sh
set -e -x

export DEBIAN_FRONTEND=noninteractive

### Basic update/upgrade
apt-get update
apt-get upgrade -y

## Force UTC from the very beginning
echo Etc/UTC > /etc/timezone
dpkg-reconfigure tzdata

## Base packages
apt-get install -y vim curl

### Ruby deps & RVM
if ! which rvm > /dev/null ; then
    apt-get update
    apt-get build-dep -y ruby1.9.1
    curl -L https://get.rvm.io | bash -s stable --ruby
fi

usermod -a -G rvm vagrant
