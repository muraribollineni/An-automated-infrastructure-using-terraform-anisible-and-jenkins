---
 - name:  provisioning a new EC2 using Ansible 
   hosts: localhost
   connection: local
   gather_facts: False
   tags: provisioning

   vars:
     instance_type: t2.micro
     image: ami-08b5b3a93ed654d19
     wait: yes
     group: webserver
     count: 1
     region: us-east-1
     security_group: ec2-security-group
   
   tasks:

     - name: Create a security group
       local_action: 
         module: ec2_group
         name: "{{ security_group }}"
         description: Security Group for webserver Servers
         region: "{{ region }}"
         rules:
            - proto: tcp
              from_port: 22
              to_port: 22
              cidr_ip: 0.0.0.0/0
            - proto: tcp
              from_port: 8080
              to_port: 8080
              cidr_ip: 0.0.0.0/0
            - proto: tcp
              from_port: 80
              to_port: 80
              cidr_ip: 0.0.0.0/0
            - proto: tcp
              from_port: 443
              to_port: 443
              cidr_ip: 0.0.0.0/0
         rules_egress:
            - proto: all
              cidr_ip: 0.0.0.0/0
       register: basic_firewall
     
     - name: Launch the new EC2 Instance
       local_action:  ec2 
                      group={{ security_group }} 
                      instance_type={{ instance_type}} 
                      image={{ image }} 
                      wait=true 
                      region={{ region }} 
                      keypair={{ keypair }}
                      count={{count}}
       register: ec2
     - name: Task # 3 Add Tagging to EC2 instance
       local_action: ec2_tag resource={{ item.id }} region={{ region }} state=present
       with_items: "{{ ec2.instances }}"
       args:
         tags:
           Name: MyTargetEc2InstanceHello, this is my first GitHub push!
