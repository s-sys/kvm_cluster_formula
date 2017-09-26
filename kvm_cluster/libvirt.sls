# Update /etc/hosts for server entries
{% set t = "" %}
{% for server, addrs in salt['mine.get']('kvm-*', 
  'network.ip_addrs', 
  expr_form='compound') | dictsort() %}
{% if server != t %}
hosts-{{ server }}:
  host.present:
    - ip: {{ addrs[0] }}
    - names: 
      - {{ server }}
{% endif %}
{% set t = server %}
{% endfor %}

# Load KVM and watchdog modules
load_kvm:
  kmod.present:
    - mods:
      - kvm
      - softdog

# Createlocal mount directory structure
/export/vms:
  file.directory:
    - user: qemu
    - group: qemu
    - mode: 770
    - makedirs: True

# Define libvirtd service
libvirtd.service:
  service.running:
    - enable: False
    - reload: True
    - require:
      - install_suse_base
      - load_kvm
      - /export/vms
    - watch:
      - file: /etc/libvirt/libvirt-admin.conf
      - file: /etc/libvirt/libvirt.conf
      - file: /etc/libvirt/libvirtd.conf
      - file: /etc/libvirt/qemu.conf
      - file: /etc/sysconfig/libvirtd

/etc/libvirt/libvirt-admin.conf:
  file.managed:
    - source: salt://kvm_cluster/files/libvirt/libvirt-admin.conf
    - user: root
    - group: root
    - mode: 644

/etc/libvirt/libvirt.conf:
  file.managed:
    - source: salt://kvm_cluster/files/libvirt/libvirt.conf
    - user: root
    - group: root
    - mode: 644

/etc/libvirt/libvirtd.conf:
  file.managed:
    - source: salt://kvm_cluster/files/libvirt/libvirtd.conf
    - user: root
    - group: root
    - mode: 644
    
/etc/libvirt/qemu.conf:
  file.managed:
    - source: salt://kvm_cluster/files/libvirt/qemu.conf
    - user: root
    - group: root
    - mode: 644

/etc/sysconfig/libvirtd:
  file.managed:
    - source: salt://kvm_cluster/files/libvirt/libvirtd
    - user: root
    - group: root
    - mode: 644

# Install libvirt keys for live migration support
libvirt_keys:
  virt.keys

# Define /export/vms as a storage pool on each node
create_libvirt_storage_pool_nfs:
  cmd.run:
    - name: virsh pool-create-as --type dir --name nfs --target "/export/vms"
    - unless: virsh pool-info nfs
    - require: 
      - /export/vms

start_libvirt_storage_pool_nfs:
  cmd.run:
    - name: virsh pool-start nfs
    - unless: virsh pool-info nfs | grep -i ^state | grep -i running
    - require: 
      - create_libvirt_storage_pool_nfs

