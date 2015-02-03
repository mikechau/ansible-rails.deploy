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
