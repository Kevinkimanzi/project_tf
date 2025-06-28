[webservers]
%{ for droplet in droplets ~}
${droplet.name} ansible_host=${droplet.ipv4_address} ansible_user=root
%{ endfor ~}

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3