pacemaker.service:
  service.running:
    - enable: False
    - reload: True
    - require:
      - install_suse_ha_packages
      - corosync.service
      - libvirtd.service
    - watch:
      - file: /etc/sysconfig/pacemaker
      - file: /etc/sysconfig/sbd
  file.managed:
    - name: /etc/sysconfig/pacemaker
    - source: salt://kvm_cluster/files/sysconfig/pacemaker
    - user: root
    - group: root
    - mode: 644

{% if salt['pillar.get']('ha_fencing:stonith_enabled', false) 
  and (salt['mine.get']('kvm-*', 
  'network.get_hostname', 
  expr_form='compound') | length()) >= 2 %}
pacemaker_service_dependency_directory:
  file.directory:
    - name: /etc/systemd/system/pacemaker.service.requires
    - user: root
    - group: root
    - mode: 755

pacemaker_service_dependency_sbd:
  file.symlink:
    - name: /etc/systemd/system/pacemaker.service.requires/sbd.service
    - target: /usr/lib/systemd/system/sbd.service
    - require:
      - pacemaker_service_dependency_directory

service.systemctl_reload:
  module.run:
    - onchanges:
      - pacemaker_service_dependency_sbd
      - pacemaker.service
{% endif %}

