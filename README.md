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

### Execute
Go to `http://localhost:8000`
