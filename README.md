# Dmemo [![Build Status](https://semaphoreci.com/api/v1/hogelog/dmemo/branches/master/badge.svg)](https://semaphoreci.com/hogelog/dmemo)
Database description management tool.


## Setup
```
$ bundle install
$ ./bin/rake bower:install
$ ./bin/rake db:create
$ ./bin/rake ridgepole:apply
$ ./bin/rails s
```

### Docker

Docker images published on Docker Hub.
https://hub.docker.com/r/hogelog/dmemo/

```
$ cp .env.sample .env.docker
$ vi .env.docker
...
$ docker run --rm --env-file .env.docker -t hogelog/dmemo ./bin/docker_db_apply.sh
$ docker-compose up
```

## Execute synchronization
```
./bin/rails r 'SynchronizeDataSources.run'
```

or

```
docker run --rm --env-file .env.docker -t hogelog/dmemo ./bin/rails r 'SynchronizeDataSources.run'
```


## Configure
### Create Admin User
- Login dmemo by google account
- Activate user as admin
```
$ ./bin/rake admin:activate EMAIL=konbu.komuro@gmail.com
 or
$ docker run --env-file .env.docker hogelog/dmemo ./bin/docker_admin_activate.sh konbu.komuro@gmail.com
```
