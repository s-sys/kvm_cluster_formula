# Install SUSE base components for KVM
install_suse_base:
  cmd.run:
    - name: zypper --non-interactive in -t pattern base x11 kvm_server kvm_tools

# Install SUSE HA
install_suse_ha_packages:
  cmd.run:
    - name: zypper --non-interactive in -t pattern ha_sles

# Install additional SUSE Packages
install_packages:
  pkg.installed:
    - pkgs:
      - virt-top
    - require: 
      - install_suse_base

