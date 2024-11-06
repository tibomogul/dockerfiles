# dockerfiles
Repository for Dockerfiles shared with the world. Hope you find this helpful.

# IMPORTANT: Map your user ID and GID
When using Docker for development you normally bind a local directory to the container. This local directory contains the source code that you want to retain between container runs. If your user id and group id do not line up with those in the container you can get into permission problems.

The base images are built with user id 1000 and group id 1000. If yours is different it will cause problems with volume mappings. The image ENTRYPOINT script `check_ownership` run checks and aborts if the ids do not line up. The user must supply `DOCKER_UID` and `DOCKER_GID` when running a container.

For example, using `docker run`, this starts a container with `bash -l`
```
docker run --rm -it \
  -e DOCKER_UID=$(id -u) \
  -e DOCKER_GID=$(id -g) \
  tibomogul/obsidian-slides-extended
```

Using `docker compose`, this starts the container to be exec'd to.
```
    environment:
      DOCKER_UID: $DOCKER_UID
      DOCKER_GID: $DOCKER_GID
    command: ['sleep', 'infinity']
```

You can also just build your base image with the Dockerfile in this repo, replacing the user id and group id.

Using `docker build`,
```
docker build . \
  --build-arg build_docker_uid=$(id -u) \
  --build-arg build_docker_gid=$(id -g) \
  -f Dockerfile-rbenv_nvm \
  -t myownimage
```

Or in `docker compose`
```
    build:
      context: ./
      args:
        build_docker_uid: $DOCKER_UID
        build_docker_gid: $DOCKER_GID
```

You will still need to declare the env vars if you use the provided entrypoint script.

# sample usage

## Running the base image and starting a Rails project

1. Create an empty folder for your project and change to that directory. Note that the directory name you use will dictate the application name generated by `rails new`. For example, we use `my_app` as the directory, generating the camelcase `MyApp` as the rails application name.
```
mkdir -p ~/projects
cd ~/projects
mkdir my_app
cd my_app
```

2. Run a temporary container, but make sure to update the command with the correct directory, that you just created. In this case, the directory is `my_app` in the volume mapping `-v .:/home/user/my_app`
```
docker run --rm -it \
  -v .:/home/user/my_app \
  -p 3000:3000 \
  -e DOCKER_UID=$(id -u) \
  -e DOCKER_GID=$(id -g) \
  tibomogul/rbenv_nvm
```

3. Install rails and generate the new rails application in `my_app`
```
$ gem install rails
$ rails new my_app
$ cd my_app
$ bin/rails s -b 0.0.0.0
```

### If you use repos on SCMs that need SSH access
Make sure your ssh credentials are in ssh-agent. For example, in your `.bashrc`,
```
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
fi
```
And map into the container
```
docker run --rm -it \
  -v $SSH_AUTH_SOCK:/ssh-agent \
  -v .:/home/user/my_app \
  -p 3000:3000 \
  -e SSH_AUTH_SOCK=/ssh-agent \
  -e DOCKER_UID=$(id -u) \
  -e DOCKER_GID=$(id -g) \
  tibomogul/rbenv_nvm
```

### If you plan to push
Add the name and email of your git user to you environment
```
export GIT_COMMITTER_NAME="Tibo Mogul"
export GIT_COMMITTER_EMAIL=tibo.mogul@gmail.com
```
And use as environment parameters
```
docker run --rm -it \
  -v .:/home/user/my_app \
  -p 3000:3000 \
  -e DOCKER_UID=$(id -u) \
  -e DOCKER_GID=$(id -g) \
  -e GIT_COMMITTER_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_COMMITTER_EMAIL="$GIT_COMMITTER_EMAIL" \
  -e GIT_AUTHOR_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_AUTHOR_EMAIL="$GIT_COMMITTER_EMAIL" \
  tibomogul/rbenv_nvm
```

### If both
```
docker run --rm -it \
  -v $SSH_AUTH_SOCK:/ssh-agent \
  -v .:/home/user/my_app \
  -p 3000:3000 \
  -e DOCKER_UID=$(id -u) \
  -e DOCKER_GID=$(id -g) \
  -e GIT_COMMITTER_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_COMMITTER_EMAIL="$GIT_COMMITTER_EMAIL" \
  -e GIT_AUTHOR_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_AUTHOR_EMAIL="$GIT_COMMITTER_EMAIL" \
  -e SSH_AUTH_SOCK=/ssh-agent \
  tibomogul/rbenv_nvm
```

### Changing the timezone (for your sanity)
Using `docker build`, so it is the default in your images,
```
docker build . \
  --build-arg build_timezone=Australia/Brisbane \
  -f Dockerfile-rbenv_nvm \
  -t myownimage
```

Or in `docker compose`, if you build an image
```
    build:
      context: ./
      args:
        build_timezone: Australia/Brisbane
```
Or in `docker compose`, if you use a pre-built image,
```
    environment:
      TZ: Australia/Brisbane
```

Or just `docker run`
```
docker run --rm -it \
  -e TZ=Australia/Brisbane \
  tibomogul/rbenv_nvm
```

## Extending the base image

### Ruby

```
FROM tibomogul/rbenv_nvm

ENV APP_DIR=app

RUN mkdir /home/$USER_NAME/${APP_DIR}
WORKDIR /home/$USER_NAME/${APP_DIR}

# Install application utility gems
RUN gem install foreman mailcatcher

# Install application-specific gems
COPY --chown=${USER_NAME}:${USER_NAME} Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.5.1 \
  && bundle install

# Copy application code
COPY --chown=${USER_NAME}:${USER_NAME}  . .

# Entrypoint prepares the database.
ENTRYPOINT ["check_ownership", "./bin/docker-entrypoint"]

# mailcatcher
EXPOSE 1080

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["sleep", "infinity"]
```

### Node
Note that in this example, the code uses repos in Github. There are run instructions to:
- setup SSH access to Github
- mount the SSH credentials during install
```
FROM tibomogul/rbenv_nvm:user-node

ENV APP_DIR=app

RUN mkdir /home/$USER_NAME/${APP_DIR}
WORKDIR /home/$USER_NAME/${APP_DIR}

RUN mkdir -p /home/${USER_NAME}/.ssh/
RUN ssh-keyscan github.com >> /home/${USER_NAME}/.ssh/known_hosts
RUN chmod 644 /home/${USER_NAME}/.ssh/known_hosts
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /home/${USER_NAME}/.ssh/config
RUN chmod 600 /home/${USER_NAME}/.ssh/config

# Install application utility packages
# Sourcing nvm.sh is necessary as the NVM installer puts that in .bashrc
RUN source "/home/${USER_NAME}/.nvm/nvm.sh" \
  && npm install -g pnpm

# Install application-specific packages
COPY --chown=${USER_NAME}:${USER_NAME} package.json pnpm-lock.yaml ./
RUN --mount=type=ssh,mode=0666 \
  source "/home/${USER_NAME}/.nvm/nvm.sh" \
  && pnpm install

# Copy application code
COPY --chown=${USER_NAME}:${USER_NAME}  . .
```
The image is built instructing the ssh credentials to be mounted.
```
DOCKER_BUILDKIT=1 docker build --ssh default -t tibomogul/obsidian-slides-extended .
```
And run providing the credentials so you can continue doing installs within the container.
```
docker run --rm -it \
  -v $SSH_AUTH_SOCK:/ssh-agent \
  -v .:/home/node/app \
  -e DOCKER_UID=$(id -u) \
  -e DOCKER_GID=$(id -g) \
  -e GIT_COMMITTER_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_COMMITTER_EMAIL="$GIT_COMMITTER_EMAIL" \
  -e GIT_AUTHOR_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_AUTHOR_EMAIL="$GIT_COMMITTER_EMAIL" \
  -e SSH_AUTH_SOCK=/ssh-agent \
  tibomogul/obsidian-slides-extended
```


# building

```
docker build . \
  --build-arg build_docker_uid=$(id -u) \
  --build-arg build_docker_gid=$(id -g) \
  -f Dockerfile-rbenv_nvm \
  -t tibomogul/rbenv_nvm
```

Changing parameters. You can change the following:
- build_user_name (default: user)
- build_app_dir (default: app)
- build_node_version (default: 20.16.0)
- build_nvm_install_version (default: v0.40.0)
- build_ruby_version (default: 3.3.4)
- build_timezone (default: Etc/Universal, e.g. Australia/Brisbane)
```
docker build . \
  --build-arg build_docker_uid=$(id -u) \
  --build-arg build_docker_gid=$(id -g) \
  --build-arg build_user_name=node \
  --build-arg build_timezone=Australia/Brisbane \
  -f Dockerfile-rbenv_nvm \
  -t tibomogul/rbenv_nvm:user-node
```

# extending

```
RUN mkdir -p /home/${USER_NAME}/.ssh/
RUN echo "Host bitbucket.org\n\tStrictHostKeyChecking no\n" >> /home/${USER_NAME}/.ssh/config
RUN chmod 600 /home/${USER_NAME}/.ssh/config
```

Changing ownership
```
old_gid=$(id -g)
old_uid=$(id -u)
usermod -u ${DOCKER_UID} ${USER_NAME}
groupmod -g ${DOCKER_GID} ${USER_NAME}
find / -group $old_gid -exec sudo chgrp -h ${DOCKER_GID} {} \;
find / -user $old_uid -exec sudo chown -h ${DOCKER_UID} {} \;
```

Running bypassing the entrypoint
```
docker run -it --entrypoint /bin/bash tibomogul/rbenv_nvm
```

Bypassing the entrypoint in the Dockerfile
```
ENTRYPOINT []
```

When used as a base image, you can call the existing entrypoint first
```
ENTRYPOINT ["check_ownership", "new_entrypoint"]
```