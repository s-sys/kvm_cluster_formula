{% set sbd = salt['pillar.get']('sbd_storage') %}

# Enable SBD service and check SBD device for setup
sbd_file:
  file.managed:
    - name: /etc/sysconfig/sbd
    - source: salt://kvm_cluster/files/sysconfig/sbd
    - template: jinja
    - user: root
    - group: root
    - mode: 644

sbd_block_device:
  cmd.run:
    - name: iscsiadm -m discovery -t sendtargets -p {{ sbd.ip }} && iscsiadm -m node --targetname {{ sbd.iqn_name }} --portal {{ sbd.ip }}:{{ sbd.port }} --login
    - unless: test -b {{ sbd.block_device }}
    - require:
      - iscsi.service

iscsi.service:
  service.running:
    - enable: False
    - reload: True
    - require:
      - install_suse_base
    - watch:
      - file: /etc/iscsi/iscsid.conf
  file.managed:
    - name: /etc/iscsi/iscsid.conf
    - source: salt://kvm_cluster/files/iscsi/iscsid.conf
    - user: root
    - group: root
    - mode: 600

sbd_block_device_format:
  cmd.run:
    - name: sbd -d {{ sbd.block_device }} create
    - unless: sbd -d {{ sbd.block_device }} list
    - require:
      - iscsi.service
      - sbd_block_device

