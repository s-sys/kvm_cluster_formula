# Enable HAWK for web interface management
hawk.service:
  service.running:
    - enable: False
    - reload: True
    - require:
      - install_suse_ha_packages

