# Possible docker-compose/Docker Compose inconsistency

Noted on 2021-06-24 with the help of @cloudycelt - any misunderstandings or confusion
are due to my newbie-ness with Docker and not their fault :P

## Summary of issue

When a `docker-compose.yml` service definition includes a mount of a host directory,
and the destination mount point is changed between executions of `docker(-/ )compose up`,
the behaviour of the two tools differs:
* The container that results from `docker-compose up` mounts the host directory to only the
    newly-specified location (as I would expect).
* The container that results from `docker compose up` mounts the host directory to both the
    old and the new location (and, if the name is changed again, to all _three_ locations,
    and so on).

## Steps to reproduce

* Check out repo
* `$ mkdir /tmp/bugdemo`
* `$ touch /tmp/bugdemo/file1`
* `$ docker compose up`
  * Expected output:
    * `/demonstration/bugdemo1/file1`
  * Actual matches expectation
* In `docker-compose.yml`, change `/tmp/bugdemo:/demonstration/bugdemo1` to `/tmp/bugdemo:/demonstration/bugdemo2`
* `$ docker compose up`
  * Expected output:
    * `/demonstration/bugdemo2/file1`
  * Actual output:
    * `/demonstration/bugdemo2/file1`
    * `/demonstration/bugdemo1/file1`
* `$ touch /tmp/bugdemo/file2` (to demonstrate that `bugdemo` isn't an old cached volume, but is being updated)
* `$ docker compose up`
  * Expected output:
    * `/demonstration/bugdemo2/file2`
    * `/demonstration/bugdemo2/file1`
  * Actual output:
    * `/demonstration/bugdemo2/file2`
    * `/demonstration/bugdemo2/file1`
    * `/demonstration/bugdemo1/file2`
    * `/demonstration/bugdemo1/file1`
* Change `/tmp/bugdemo:/demonstration/bugdemo2` to `/tmp/bugdemo:demonstration/bugdemo3`
* `$ docker compose up`
  * Expected output:
    * `/demonstration/bugdemo3/file2`
    * `/demonstration/bugdemo3/file1`
  * Actual output:
    * `/demonstration/bugdemo3/file2`
    * `/demonstration/bugdemo3/file1`
    * `/demonstration/bugdemo2/file2`
    * `/demonstration/bugdemo2/file1`
    * `/demonstration/bugdemo1/file2`
    * `/demonstration/bugdemo1/file1`
* `$ docker ps --all --filter "name=dockercomposebug" -q | xargs -I {} docker rm {}`
* `$ docker compose up`
  * Expected output:
    * `/demonstration/bugdemo3/file2`
    * `/demonstration/bugdemo3/file1`
  * Actual matches expectation

The same steps with `docker-compose` instead of `docker compose` match expectations
throughout.

Replacing `docker compose up` with `docker compose build --no-cache && docker compose up` throughout still displays the unexpected behaviour.

### System configuration

* Mac OS 10.15.7
* docker-compose version `docker-compose version 1.29.1, build c34c88b2`
* Docker version `Docker version 20.10.6, build 370c289`