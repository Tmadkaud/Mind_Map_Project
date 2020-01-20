Vagrant.configure("2") do |config|
  config.vm.hostname = 'nbc-test'
  config.vm.box = "ubuntu/xenial64"
  config.vm.network :forwarded_port, host: 80, guest: 80

  config.vm.provision "docker",
    images: ["python:3"]

  config.vm.provision "shell",
    inline: "apt install docker-compose -y; cd /vagrant; docker-compose up -d"
end
