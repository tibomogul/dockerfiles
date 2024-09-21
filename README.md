# dockerfiles
Repository for Dockerfiles shared with the world. Hope you find this helpful.

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
  tibomogul/rbenv_nvm \
  bash -l
```

3. Install rails and generate the new rails application in `my_app`
```
$ gem install rails
$ rails new my_app
$ cd my_app
$ bin/rails s -b 0.0.0.0
```

### If you use private repos

```
docker run --rm -it \
  -v $SSH_AUTH_SOCK:/ssh-agent \
  -v .:/home/user/app \
  -e GIT_COMMITTER_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_COMMITTER_EMAIL="$GIT_COMMITTER_EMAIL" \
  -e GIT_AUTHOR_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_AUTHOR_EMAIL="$GIT_COMMITTER_EMAIL" \
  -e SSH_AUTH_SOCK=/ssh-agent \
  tibomogul/rbenv_nvm \
  bash -l
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
ENTRYPOINT ["./bin/docker-entrypoint"]

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
  -e GIT_COMMITTER_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_COMMITTER_EMAIL="$GIT_COMMITTER_EMAIL" \
  -e GIT_AUTHOR_NAME="$GIT_COMMITTER_NAME" \
  -e GIT_AUTHOR_EMAIL="$GIT_COMMITTER_EMAIL" \
  -e SSH_AUTH_SOCK=/ssh-agent \
  tibomogul/obsidian-slides-extended \
  bash -l
```


# building

```
docker build . -f Dockerfile-rbenv_nvm -t tibomogul/rbenv_nvm
```

Changing parameters. You can change the following:
- build_user_name (default: user)
- build_app_dir (default: app)
- build_node_version (default: 20.16.0)
- build_nvm_install_version (default: v0.40.0)
- build_ruby_version (default: 3.3.4)
```
docker build . \
  --build-arg build_user_name=node \
  -f Dockerfile-rbenv_nvm \
  -t tibomogul/rbenv_nvm:user-node
```

# extending

```
RUN mkdir -p /home/${USER_NAME}/.ssh/
RUN echo "Host bitbucket.org\n\tStrictHostKeyChecking no\n" >> /home/${USER_NAME}/.ssh/config
RUN chmod 600 /home/${USER_NAME}/.ssh/config
```
