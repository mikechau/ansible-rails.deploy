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
