# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

options = {
  :vm_box => "hashicorp/precise64",
  :vm_prefix => "vm",
  :nodes => 3,
  :base_ip => "33.33.10",
  :ip_increment => 10,
  :forwarded_ports => [],
  :port_increment => 100,
  :cores => 1,
  :memory => 512,
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |cluster|
  (1..options[:nodes].to_i).each do |index|
    last_octet = index * options[:ip_increment].to_i

    cluster.vm.define "#{options[:vm_prefix]}#{index}".to_sym do |config|
      # Use package cache if it's installed.
      # http://fgrehm.viewdocs.io/vagrant-cachier/usage/
      if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
        config.cache.enable :apt
        config.cache.enable :generic, {"wget" => { cache_dir: "/var/cache/wget" }}
      end

      # Configure the VM and operating system.
      config.vm.box = options[:vm_box]
      config.vm.provider(:virtualbox) {|v| v.customize ["modifyvm", :id,
                                                        "--memory", options[:memory].to_i,
                                                        "--cpus",   options[:cores].to_i]}
      # Setup the network
      options[:forwarded_ports].each do |port|
          forwarded_port = port + ((index - 1) * options[:port_increment])
          config.vm.network :forwarded_port, guest: port, host: forwarded_port
      end

      hostname = "#{options[:vm_prefix]}#{index}"
      address = "#{options[:base_ip]}.#{last_octet}"

      config.vm.hostname = hostname
      config.vm.network :private_network, ip: address

      config.vm.provision "shell", path: "install.sh", args: [hostname, address]
    end
  end
end
