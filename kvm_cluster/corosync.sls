{% from "kvm_cluster/map.jinja" import cluster with context %}
{% from "kvm_cluster/map.jinja" import multicast with context %}

# Enable and start cluster services
corosync.service:
  service.running:
    - enable: False
    - reload: True
    - require:
      - install_suse_ha_packages
    - watch:
      - file: /etc/corosync/corosync.conf
      - file: /etc/corosync/authkey

/etc/corosync/authkey:
  file.managed:
    - name: /etc/corosync/authkey
    - source: salt://kvm_cluster/files/corosync/authkey
    - user: root
    - group: root
    - mode: 400

/etc/corosync/corosync.conf:
  file.managed:
    - source:  salt://kvm_cluster/files/corosync/corosync.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644

