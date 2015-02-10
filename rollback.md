# ROLLBACK

Must specify release version.

1. go to current app/id
  - detach process from LB
  - set to maintenance mode (remove ok.html)

  - wait for detached from LB
  - wait for port to be drained

- release is specified

2. rollback
  - remove current application
  - copy release to current application
  - generate application configs
  - symlink to shared logs
  - symlink to run
  - generate passenger binstubs
  - start passenger
  - wait for port to open
  - wait for passenger to start
  - attach application to haproxy
  - check if application is up
  - allow traffic to application
  - wait for healthcheck to be up

---

# ROLLBACK

# Phase Preliminary

## Check if we can deploy by checking haproxy status
_haproxy_statuscheck_up
  requirements:
    - first

## Detach instance from haproxy
_haproxy_detach
  requirements:
    - rails_app_haproxy
    - haproxyctl_is_installed

_rvm_passenger_stop.yml
  => set_fact register single instance

_port_stop_listening.yml

# Phase Release

- set increment new release (f)

# Phase Deploy
_current_set
_binstubs
_rvm_passenger_start
_port_start_listening
_haproxy_attach
_ping_server
_haproxy_healthcheck_up