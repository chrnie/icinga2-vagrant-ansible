# icinga2-vagrant-ansible
Run some demo config on two virtual machines.
Use vagrant and ansible to deploy this test environment.

## Introduction

this playbook gives you a running test environment with following features:
  - icinga2 master and client
    - feature ido
    - feature graphite
  - icingaweb2
    - business process module
    - graphite module
    - ...
  - graphite&kibana
  - jasperserver

Icinga2 config contains some fully simulated dummy hosts and services from https://github.com/chrnie/icinga2-demo

## Requirements

Required roles are installed using git submodules because it's easier to commit changes to the right place and keep control about the whole versioning.

### git clone with submodules

```sh
$ git clone --recursive git@github.com:chrnie/icinga2-vagrant-ansible.git
```

### managing git submodules

if you cloned the playbook without submodules, init them

```sh
$ git submodule update --init
```

add a new submodule

```sh
$ git submodule add git@github.com:chrnie/ansible-role-icingaweb2.git roles/chrnie.icingaweb2
```

more commands

```sh
$ git submodule update
$ git submodule status
$ git status -s
