# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

require 'ostruct'

opt = OpenStruct.new
def opt.hostname(index)
  "#{vm_prefix}#{index}"
end

def opt.address(index)
  "#{base_ip}.#{last_octet(index)}"
end

def opt.last_octet(index)
  index * ip_increment
end

opt.vm_box         = "hashicorp/precise64"
opt.vm_prefix      = "spark"
opt.nodes          = 3
opt.base_ip        = "33.33.10"
opt.ip_increment   = 10
opt.port_increment = 100
opt.cores          = 2
opt.memory         = 2048

Vagrant.configure(VAGRANTFILE_API_VERSION) do |cluster|
  (1..opt.nodes).each do |index|

    cluster.vm.define "#{opt.hostname(index)}".to_sym do |config|
      # Use package cache if it's installed.
      # http://fgrehm.viewdocs.io/vagrant-cachier/usage/
      if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
        config.cache.enable :apt
        config.cache.enable :generic, {"wget" => { cache_dir: "/var/cache/wget" }}
      end
      if Vagrant.has_plugin?("vagrant-hosts")
        config.vm.provision :hosts do |provisioner|
          (1..opt.nodes).each do |idx|
            provisioner.add_host opt.address(idx), [opt.hostname(idx)]
          end
        end
      end

      # Configure the VM and operating system.
      config.vm.box = opt.vm_box
      config.vm.provider(:virtualbox) {|v| v.customize ["modifyvm", :id,
                                                        "--memory", opt.memory,
                                                        "--cpus",   opt.cores]}

      config.vm.hostname = opt.hostname(index)
      config.vm.network :private_network, ip: opt.address(index)

      config.vm.provision "shell", path: "install.sh", args: [opt.hostname(index), opt.address(index)]
    end
  end
end
