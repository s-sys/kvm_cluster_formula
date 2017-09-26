# Enable Csync2 service
csync2.socket:
  service.running:
    - enable: False
    - reload: True
    - require:
      - install_suse_ha_packages
    - watch:
      - file: /etc/csync2/csync2.cfg
      - file: /etc/csync2/key_hagroup
      - file: /etc/csync2/csync2_ssl_cert.pem
      - file: /etc/csync2/csync2_ssl_key.pem

/etc/csync2/csync2.cfg:
  file.managed:
    - name: /etc/csync2/csync2.cfg
    - source:  salt://kvm_cluster/files/csync2/csync2.cfg
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/etc/csync2/csync2_ssl_cert.pem:
  file.managed:
    - source:  salt://kvm_cluster/files/csync2/csync2_ssl_cert.pem
    - user: root
    - group: root
    - mode: 600

/etc/csync2/csync2_ssl_key.pem:
  file.managed:
    - source:  salt://kvm_cluster/files/csync2/csync2_ssl_key.pem
    - user: root
    - group: root
    - mode: 600

/etc/csync2/key_hagroup:
  file.managed:
    - source:  salt://kvm_cluster/files/csync2/key_hagroup
    - user: root
    - group: root
    - mode: 600

