# Rails Deploy Ansible Role

This is a role for deploying `Ruby on Rails` applications, for rolling upgrades via `Haproxy` and `Phusion Passenger`.

Currently it assumes you are using:

- CentOS
- Haproxy
- Phusion Passenger Standalone
- RVM

## Todo

- Worker Handling
- Ubuntu compatibility.
- Add tests.

## Getting Started

Check out `defaults/main.yml` for all the configuration options.

Here is what you should configure at a minimal:

Your `group_var`:

```yaml
rails_app_name: "{{ app_name }}"
rails_app_user: "{{ app_user }}"
rails_app_http_check_uri: "{{ app_healthcheck_uri }}"

rails_app_host: 127.0.0.1
rails_app_platform: "{{ app_user }}"
rails_app_production_ready: true
rails_app_purge_all: false

rails_app_git_repo: https://github.com/mikechau/haproxy-passenger-standalone-rolling-upgrades.git
rails_app_git_branch: master

rails_app_all_instances:
  - id: titanium
    port: 4000
    host: 127.0.0.1
    protocol: tcp

  - id: carbon
    port: 4001
    host: 127.0.0.1
    protocol: tcp

rails_app_rvm: true

rails_app_haproxyctl: true

rails_app_db_username: "{{ db_user }}"
rails_app_db_password: "{{ db_pass }}"

rails_app_env_config:
  APPLICATION_NAME: "{{ app_name }}"

rails_app_environment:
  RAILS_ENV: production
```

Your playbook:

```yaml
  vars:
    rails_app_strategy: deploy
    rails_app_platform: production
  roles:
    - role: rails
      rails_app_run: first
      rails_app_type: server
      rails_app_id: titanium
      rails_app_host: 127.0.0.1
      rails_app_port: 4000

    - role: rails
      rails_app_run: last
      rails_app_type: server
      rails_app_id: carbon
      rails_app_host: 127.0.0.1
      rails_app_port: 4001
```

This role was designed to deploy multiple instances of the same `Rails` application to the same host. Utilizing `Haproxy`, it executes deployments through a rolling update strategy.

## LICENSE

MIT
