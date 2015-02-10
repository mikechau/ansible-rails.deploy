# DEPLOY STRATEGY

1. go into current app/id
  - detach process from LB
  - set to maintenance mode (remove ok.html)

  - wait for detached from LB
  - wait for port to be drained

2. build process (once)
  - checkout git repo (run once)
  - clean up build directory (run once)
  - bundle install (run once)
  - generate application configs (run once)
  - rake db migrate (run once)
  - precompile assets (run once)

3. get last release (once)
  - set release version from last deploy (run once)
  - increment new release (run once)
  - get new release path (run once)
  - copy build to release (run once)

4. application deploy
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

# DEPLOY

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

# Phase setup
- create app dirs

# Phase Build (first)

_git.yml
_copy_cmd.yml
_rvm_bundle.yml
_config.yml
_rvm_rake_db.yml
_rvm_rake_precompile.yml

# Phase Release

_release_last_version (first)
- set increment new release (f)
- set new release path (f)
- copy build to release (f)

# Phase Deploy
_current_set
_binstubs
_rvm_passenger_start
_port_start_listening
_haproxy_attach
_ping_server
_haproxy_healthcheck_up