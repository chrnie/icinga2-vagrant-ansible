# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
VAGRANT_REQUIRED_VERSION = "1.6.5"
VAGRANT_REQUIRED_LINKED_CLONE_VERSION = "1.8.4"

# Require 1.6.5 at least
if ! defined? Vagrant.require_version
  if Gem::Version.new(Vagrant::VERSION) < Gem::Version.new(VAGRANT_REQUIRED_VERSION)
    puts "Vagrant >= " + VAGRANT_REQUIRED_VERSION + " required. Your version is " + Vagrant::VERSION
    exit 1
  end
else
  Vagrant.require_version ">= " + VAGRANT_REQUIRED_VERSION
end

nodes = { 'kerrigan.bug.int' => {
            :box_virtualbox => 'bento/centos-7.4',
            :box_parallels  => 'parallels/centos-7.4',
            :box_libvirt    => 'centos/7',
            :mac	=> '020027006100',
            :net	=> 'bug.int',
            :hostonly   => '192.168.33.31',
            :memory	=> '3072',
            :cpus	=> '2',
            :forwarded	=> {
              '443'  => '8445',
              '80'   => '8085',
              '22'   => '2085'
            }
          },
          'zasz.bug.int' => {
            :box_virtualbox => 'bento/debian-9.2',
            :box_parallels  => 'parallels/debian-9.2',
            :box_libvirt    => 'debian/9',
            :mac	=> '020027006200',
            :net	=> 'bug.int',
            :hostonly   => '192.168.33.32',
            :memory	=> '1024',
            :cpus	=> '2',
            :forwarded	=> {
              '443'  => '8446',
              '80'   => '8086',
              '22'   => '2086'
            }
          }
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # activate hostmanager plugin
  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
  end
  nodes.each_pair do |name, options|
    config.vm.define name do |node_config|
      node_config.vm.box = options[:box_virtualbox]
      node_config.vm.hostname = name
      node_config.vm.box_url = options[:url] if options[:url]
      if options[:forwarded]
        options[:forwarded].each_pair do |guest, local|
          node_config.vm.network "forwarded_port", guest: guest, host: local
        end
      end

      node_config.vm.network :private_network, ip: options[:hostonly] if options[:hostonly]
#      node_config.hostmanager.aliases = [ name ]


      # provider: parallels
      node_config.vm.provider :parallels do |p, override|
        override.vm.box = options[:box_parallels]
        override.vm.boot_timeout = 600

        p.name = "Icinga 2: #{name.to_s}"
        p.update_guest_tools = false
        p.linked_clone = true if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new(VAGRANT_REQUIRED_LINKED_CLONE_VERSION)

        # Set power consumption mode to "Better Performance"
        p.customize ["set", :id, "--longer-battery-life", "off"]

        p.memory = options[:memory] if options[:memory]
        p.cpus = options[:cpus] if options[:cpus]
      end

      # provider: virtualbox
      node_config.vm.provider :virtualbox do |vb, override|
        if Vagrant.has_plugin?("vagrant-vbguest")
          node_config.vbguest.auto_update = false
        end
        vb.linked_clone = true if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new(VAGRANT_REQUIRED_LINKED_CLONE_VERSION)
        vb.name = name
        vb.gui = options[:gui] if options[:gui]
        vb.customize ["modifyvm", :id,
          "--groups", "/Icinga Vagrant/" + options[:net],
          "--memory", "512",
          "--cpus", "1",
          "--audio", "none",
          "--usb", "on",
          "--usbehci", "off",
          "--natdnshostresolver1", "on"
        ]
        vb.memory = options[:memory] if options[:memory]
        vb.cpus = options[:cpus] if options[:cpus]
      end

      # provider: libvirt
      node_config.vm.provider :libvirt do |lv, override|
        override.vm.box = options[:box_libvirt]
        lv.memory = options[:memory] if options[:memory]
        lv.cpus = options[:cpus] if options[:cpus]
      end

      # provisioner: ensure that hostonly network is up
      #
      # workaround for Vagrant >1.8.4-1.9.1 not bringing up eth1 properly
      # https://github.com/mitchellh/vagrant/issues/8096
      #node_config.vm.provision "shell", inline: "service network restart", run: "always"

      # provisioner: install requirements
      node_config.vm.provision :shell, :path => "./shell_provisioner.sh"

      # provisioner: install box using ansible
      node_config.vm.provision "ansible" do |ansible|
        ansible.playbook = "vagrant_provision.yml"
        ansible.inventory_path = "hosts/testing"
        ansible.become = true
      end

      # print a friendly message
      node_config.vm.provision "shell", inline: <<-SHELL
        echo "Finished installing the Vagrant box '#{name}'."
        echo "Navigate to http://#{options[:hostonly]}"
      SHELL
    end
  end
end

