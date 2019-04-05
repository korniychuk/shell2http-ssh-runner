[![Build Status](https://travis-ci.com/korniychuk/shell2http-ssh-runner.svg?branch=master)](https://travis-ci.com/korniychuk/shell2http-ssh-runner)

## Usage

### Using a bash command 

**Mode:** `script-file`

**Variables:**  
* `REMOTE_COMMAND` _(required)_ - file name that should be located at the `/code` directory
* `TARGET_URL` - change HTTP Method. , default value is `POST:/`

**Docker Compose file:**
```
    version: '3'

    services:
      shell2http:
        image: docker.korniychuk.pro/shell2http-ssh-runner
        ports:
          - 8000:8080
        environment:
          SSH_USERNAME: ssh-user-name
          SSH_SERVER: ssh-server.com
          RUNNER_MODE: command
          REMOTE_COMMAND: cd ~ && ls -laH && docker-compose --version
        volumes:
          - "~/.ssh/id_rsa:/code/ssh.key:ro"
```

### Using a bash script file

**Mode:** `script-file`

**Variables:**  
* `REMOTE_SCRIPT_FILENAME` _(required)_ - file name that should be located at the `/code` directory
* `TARGET_URL` - change HTTP Method. , default value is `POST:/`

**Docker Compose file:**
```
    version: '3'

    services:
      shell2http:
        image: docker.korniychuk.pro/shell2http-ssh-runner
        ports:
          - 8000:8080
        environment:
          SSH_USERNAME: ssh-user-name
          SSH_SERVER: ssh-server.com
          REMOTE_SCRIPT_FILENAME: remote.sh
        volumes:
          - "~/.ssh/id_rsa:/code/ssh.key:ro"
          - "./remote-custom.sh:/code/remote.sh:ro"
```

### Using URLs file with commands

**Mode:** `urls-file-with-commands`

**Variables:**  
* `RUNNER_URLS_FILE` _(required)_ - file name that should be located at the `/code` directory

**File example:**
```
/=echo '<h1>Not Found</h1>'
GET:/ls=cd ~ && ls -la
POST:/mkdir=echo "super 3 hello !" && cd ~ && mkdir 'super test' && mkdir "super test 2" && ls -la && pwd && ls -laH
GET:/test=echo a test message
```

**Notes:**
* It is important to specify the root url `/`. Otherwise it will be potentially security issue.

**Docker Compose file:**
```
version: '3'

services:
  shell2http:
    image: docker.korniychuk.pro/shell2http-ssh-runner
    ports:
      - 8000:8080
    environment:
      SSH_USERNAME: root
      SSH_SERVER: docker.korniychuk.pro
      RUNNER_MODE: urls-file-with-commands
      RUNNER_URLS_FILE: urls.cfg
    volumes:
      - "~/.ssh/id_rsa:/code/ssh.key:ro"
      - "./test-urls.cfg:/code/urls.cfg"

```

## Settings

### Connect to the host machine

1. Create an external network bridge
`docker network create -d bridge --subnet 192.168.0.0/24 --gateway 192.168.0.1 docker-net`

```
version: '3'
...
        environment:
          SSH_SERVER: 192.168.0.1
        networks:
          - docker-net
          
networks:
    docker-net:
        external: true
```

### Setup HTTP Basic Authentication

Just add the environment variable: `SH_BASIC_AUTH`. Value is `user_name:password`.

### Execute
* Go to `http://localhost:8000`
* cURL `curl -X POST http://localhost:8000/go`
