# Building
```
docker build . \
  --build-arg build_docker_uid=$(id -u) \
  --build-arg build_docker_gid=$(id -g) \
  --build-arg build_timezone=Australia/Brisbane \
  -f Dockerfile-pyenv_nvm \
  -t tibomogul/pyenv_nvm
```

Changing parameters. You can change the following:
- build_user_name (default: user)
- build_app_dir (default: app)
- build_node_version (default: 20.16.0)
- build_nvm_install_version (default: v0.40.0)
- build_python_version (default: 3.12.3)
- build_timezone (default: Etc/Universal, e.g. Australia/Brisbane)


# Running an ephemeral container
```bash
docker run --rm -it \
  -v $DOCKER_SSH_AUTH_SOCK:/run/host-services/ssh-auth.sock \
  -v .:/home/user/my_app \
  -p 3000:3000 \
  -e DOCKER_UID=$(id -u) \
  -e DOCKER_GID=$(id -g) \
  -e GIT_COMMITTER_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_COMMITTER_EMAIL="$GIT_COMMITTER_EMAIL" \
  -e GIT_AUTHOR_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_AUTHOR_EMAIL="$GIT_COMMITTER_EMAIL" \
  -e SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock \
  tibomogul/pyenv_nvm
```
