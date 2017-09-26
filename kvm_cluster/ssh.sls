# Enable SSH
sshd.service:
  service.running:
    - enable: True

install_ssh_key:
  ssh_auth.present:
    - user: root
    - enc: ssh-rsa
    - comment: root@admin
    - names: 
      - AAAAB3NzaC1yc2EAAAADAQABAAABAQDLQDMtSTdxZRkr/+amg9tEKAFMujtD/qjPE9KVZO8svOeEFqsCC6Hyzo+SiIZvoJwDOJldsVHJXrP1wRIOVrdBQMOHP0K1aacfuWcfZUEBnRybums8KJoykONpGLFd1zzkkuZHJ+7vt1vpQCt71ZfMbF8SKfb7lRgl38ZTEZPR5PX6jDPYAiuZPuklkPI7pnLxG4Q8YDbsKd73Nwg1YXZOMpehPPCExQT3b/FwzgLxVFPbf4larhVPBc+rO37ksLvwAkMlAOWbjNUmklkqWdAikYBnzdgp2toic9YT8fvwHf7cFSiIFgcOcaFkGFEtbvpM1w9M13fYSiojhIs/K12v
    - require:
      - sshd.service

