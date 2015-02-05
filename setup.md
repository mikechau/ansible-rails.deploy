# SETUP

0. preliminary phase
  - check if current/app/id exists
  - check if passenger is running
  - stop passenger
  - remove everything except build

1. initial setup
  - set bash profile environment
  - create application pids path
  - create directories
  - create app log dir
  - symlink sockets and pids folder

2. build process (once)
  - checkout git repo
  - clean up build directory
  - bundle install
  - generate app configs
  - rake db:create
  - check schemas
  - rake db:schema load
  - precompile assets

3. release (once)
  - set initial release (0)
  - increment new release
  - get new release path
  - copy build to release

4. application deploy
  - remove current application
  - copy release to current application
  - generate application configs
  - symlink to shared logs
  - symlink to run
  - generate passenger binstubs
  - start passenger
  - wait for port to be listening
  - wait for passenger to start
  - attach application to haproxy
  - check if application is up
  - allow traffic to application
  - wait for healthcheck to be up
