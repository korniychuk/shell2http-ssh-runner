### Using an SH file
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

### Using an SH command
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

### Execute
Go to `http://localhost:8000`
