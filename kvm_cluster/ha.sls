{% set fencing = salt['pillar.get']('ha_fencing') %}
{% set sbd = salt['pillar.get']('sbd_storage') %}
{% set management = salt['pillar.get']('ha_management') %}
{% set user = salt['pillar.get']('ha_user') %}
{% set nfs = salt['pillar.get']('nfs') %}

# Cluster configuration
# Cluster user and group
ha_user:
  user.present:
    - fullname: heartbeat processes
    - shell: /bin/bash
    - name: hacluster
    - password: {{ user.password }}
    - hash_password: True
    - uid: 90
    - gid: 90
    - groups:
      - haclient
    - require:
      - install_suse_ha_packages
      - ha_group

ha_group:
  group.present:
    - name: haclient
    - gid: 90

# Tuning cluster settings, runs only on DC
{% set clusterdc = salt['cmd.run']('crmadmin -q -D 1>/dev/null') %}
{% if grains['fqdn'] == salt['cmd.run']('crmadmin -q -D 1>/dev/null') %}
ha_default_resource_stickiness:
  cmd.run:
    - name: crm configure property default-resource-stickiness=1000
    - unless: test $(crm configure get_property default-resource-stickiness) gt 0
    - require:
      - pacemaker.service

ha_setup_stonith:
  cmd.run:
    {% if salt['pillar.get']('ha_fencing:stonith_enabled', false) 
      and (salt['mine.get']('kvm-*', 
      'network.get_hostname', 
      expr_form='compound') | length()) >= 2 %}
    - name: crm configure property stonith-enabled=true
    - unless: test $(crm configure get_property stonith-enabled) == "true"
    {% else %}
    - name: crm configure property stonith-enabled=false
    - unless: test $(crm configure get_property stonith-enabled) == "false"
    {% endif %} 
    - require:
      - pacemaker.service

{% if salt['pillar.get']('ha_fencing:stonith_enabled', false) == true %}
ha_default_quorum_policy:
  cmd.run:
    - name: crm configure property no-quorum-policy="{{ management.no_quorum_policy }}"
    - unless: test $(crm configure get_property no-quorum-policy) == "{{ management.no_quorum_policy }}"
    - require:
      - pacemaker.service

ha_default_failure_timeout:
  cmd.run:
    - name: crm configure rsc_defaults failure-timeout={{ management.failure_timeout }}
    - require:
      - pacemaker.service

ha_default_migration_threshold:
  cmd.run:
    - name: crm configure rsc_defaults migration-threshold={{ management.migration_threshold }}
    - require:
      - pacemaker.service
{% endif %}

# Add admin IP address during first setup
ha_add_admin_ip:
  cmd.run:
    - name: crm configure primitive admin_addr IPaddr2 params ip={{ management.adm_ip }} op monitor interval=10 timeout=20
    - unless: crm resource list admin_addr
    - require:
      - pacemaker.service
      - ha_setup_stonith

# Add clone NFS mount to nodes
ha_add_nfs_mount_primitive:
  cmd.run:
    - name: crm configure primitive p-nfs-mount Filesystem params device="{{ nfs.server }}:{{ nfs.source_directory }}" directory="{{ nfs.mount_directory }}" fstype="nfs" op start interval=0 timeout=60 op stop interval=0 timeout=60 op monitor interval=20 timeout=40
    - unless: crm resource list p-nfs-mount
    - require:
      - pacemaker.service

ha_add_nfs_mount_clone:
  cmd.run:
    - name: crm configure clone c-nfs-mount p-nfs-mount meta target-role=Started interleave=true
    - unless: crm resource list c-nfs-mount
    - require:
      - pacemaker.service
      - ha_add_nfs_mount_primitive

# Add SBD primitive on cluster
ha_add_sbd_primitive:
  cmd.run:
    - name: crm configure primitive p-sbd stonith:external/sbd params sbd_device="{{ sbd.block_device }}" op start timeout=20 interval=0 op stop timeout=15 interval=0 op monitor timeout=20 interval=3600 meta target-role=Started
    - unless: crm resource list p-sbd
    - require:
      - pacemaker.service

# Add NodeUtilization resource on cluster
ha_add_node_utilization_primitive:
  cmd.run:
    - name: crm configure primitive p-node-utilization ocf:pacemaker:NodeUtilization op start timeout=90 interval=0 op stop timeout=100 interval=0 op monitor timeout=20s interval=60s meta target-role=Started
    - unless: crm resource list p-node-utilization
    - require:
      - pacemaker.service

ha_add_node_utilization_clone:
  cmd.run:
    - name: crm configure clone c-node-utilization p-node-utilization meta target-role=Started
    - unless: crm resource list c-node-utilization
    - require:
      - pacemaker.service
      - ha_add_node_utilization_primitive
{% endif %}

