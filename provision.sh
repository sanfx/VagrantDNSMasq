#!/bin/bash

# Always overwrite as dnsmasq.d folder always exist with original files from dnsmasq installation.
cp -rf /vagrant/dnsmasq.d/ /etc/



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

# download consul to /vagrant folder and set permission bit to executable.
if [ ! -f /vagrant/consul ]; then
    cd /vagrant
    version='1.11.1'
    wget https://releases.hashicorp.com/consul/${version}/consul_${version}_linux_amd64.zip -O consul.zip
    unzip consul.zip
    rm consul.zip

    # make consul executable
    chmod +x consul
fi

echo "Copying /vagrant/consul to /usr/bin"
ls -lrt /vagrant/consul
# Always copy the consul from /vagrant to /usr/bin location in vm
sudo cp -rf /vagrant/consul /usr/bin/

if [ ! -f /usr/bin/consul ]; then
  echo "Copying failed."
else
  chmod +x /usr/bin/consul
fi

if [ ! -f /etc/systemd/system/consul.service ]; then
    cp /vagrant/consul.service /etc/systemd/system/consul.service
fi

if [ ! -f /opt/consul ]; 
  then
    sudo mkdir /opt/consul
    chmod -R 740 /opt/consul
    chown consul:consul /opt/consul/
  fi

systemctl enable consul
# systemctl stop systemd-resolved.service
# systemctl disable systemd-resolved.service
if [ "$HOSTNAME" = dnsmasq ]; then
  systemctl restart dnsmasq
else
  printf '%s\n' "uh-oh, not on foo"
fi
systemctl start consul
systemctl status consul
systemctl status dnsmasq
echo "Finished deploying DNSMasq VM."