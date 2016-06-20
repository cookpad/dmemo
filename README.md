# Dmemo
Database description management tool.


## Setup
```
$ bundle install
$ ./bin/rake ridgepole:apply
$ ./bin/rails s
```

### Docker

```
$ cp .env.sample .env.docker
$ vi .env.docker
...
$ docker run --rm --env-file .env.docker -t hogelog/dmemo ./bin/docker_db_apply.sh
$ docker-compose up
```

