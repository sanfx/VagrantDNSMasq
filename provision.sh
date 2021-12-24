#!/bin/bash
# Always overwrite as dnsmasq.d folder always exist with original files from dnsmasq installation.
cp -rf /vagrant/dnsmasq.d /etc/

if [ ! -f /etc/systemd/system/consul.service ]; then
    cp /vagrant/consul.service /etc/systemd/system/consul.service
fi

if [ ! -d /etc/consul.d ]; then
    mkdir -p /etc/consul.d
    cp -rf /vagrant/consul.d /etc/
    chown -R consul:consul /etc/consul.d/
    chmod -R 740 /etc/consul.d/
fi

# update and unzip
dpkg -s unzip &>/dev/null || {
	apt-get -y update && apt-get install -y unzip
}

# install consul
if [ ! -f /usr/bin/consul ]; then
    cd /usr/bin

    version='1.11.1'
    wget https://releases.hashicorp.com/consul/${version}/consul_${version}_linux_amd64.zip -O consul.zip
    unzip consul.zip
    rm consul.zip

    # make consul executable
    chmod +x consul
fi

if grep -q consul /etc/group
  then
    echo "group consul exists"
  else
    groupadd --system consul
  fi


if id consul > /dev/null 2>&1
  then
      echo "user consul exist!"
  else
      useradd -s /sbin/nologin --system -g consul consul
  fi

if [ ! -f /opt/consul ]; then
    mkdir /opt/consul
    chmod -R 740 /opt/consul
    chown consul:consul /opt/consul/
fi
