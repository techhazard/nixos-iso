#!/bin/bash

set -e
which vagrant >/dev/null
which git     >/dev/null

git clone https://github.com/nixos/nixpkgs nixpkgs --depth 1 || (cd nixpkgs; git pull -f; cd ..)
vagrant up || true

cd nixpkgs/nixos/modules/installer/cd-dvd && ln -sf ../../../../../techhazard && cd -
sed -i'' -e "s!\(./installation-cd-base.nix\)!\1\n      ./techhazard/techhazard.nix!" nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix

vagrant ssh -c 'cd /vagrant/nixpkgs/nixos; nix-build -A config.system.build.isoImage -I nixos-config=modules/installer/cd-dvd/installation-cd-minimal.nix default.nix && cp -f result/iso/*.iso /vagrant/ && sync'
vagrant halt
#vagrant destroy -f

exit 0
