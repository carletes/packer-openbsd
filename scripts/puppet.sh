#!/bin/sh

set -e

if [ x$PUPPET_VERSION = x'provisionerless' ]; then
  echo "Building a box without Puppet"
else
  . /root/.profile

  if [ x$PUPPET_VERSION = x'ports' ]; then
    pkg_add puppet
  else
    groupadd -g 580 _puppet
    useradd -g _puppet -G daemon -u 580 -d /var/empty -s /sbin/nologin \
      -c "Puppet user" _puppet

    uname_r=`uname -r`
    # OpenBSD 5.6 requires Ruby 2.0
    # Previous versions requiere Ruby 1.9 (OpenBSD 5.5 has .484p0,
    # 5.4 has # .448)
    if [ $uname_r = 5.6 ]; then
      pkg_add ruby-2.0.0.481
    elif [ $uname_r = 5.5 ]; then
      pkg_add ruby-1.9.3.484p0
    else
      pkg_add ruby-1.9.3.448
    fi

    if [ $uname_r = 5.6 ]; then
      for f in ruby erb irb rdoc ri rake gem testrb facter hiera puppet ; do
        ln -sf ${f}20 /usr/local/bin/$f
      done
    else
      for f in ruby erb irb rdoc ri rake gem testrb facter hiera puppet ; do
        ln -sf ${f}19 /usr/local/bin/$f
      done
    fi

    if [ x$PUPPET_VERSION = x'latest' ]; then
      gem install puppet --no-ri --no-rdoc
    elif [ x$PUPPET_VERSION = x'prerelease' ]; then
      gem install puppet --no-ri --no-rdoc --pre
    else
      gem install puppet --no-ri --no-rdoc --version="$PUPPET_VERSION"
    fi
  fi
fi
