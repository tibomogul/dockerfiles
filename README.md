# dockerfiles
Repository for Dockerfiles shared with the world. Hope you find this helpful.

# sample usage

## Running the base image and starting a project

1. Create an empty folder for your project and change to that directory

2. Run a temporary container
```
docker run --rm -it \
  -v .:/home/user/my_app \
  -p 3000:3000 \
  tibomogul/rbenv_nvm \
  bash -l
```

3. 
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

## Ruby

```
FROM tibomogul/rbenv_nvm

# Install application utility gems
RUN gem install foreman mailcatcher

# Install application-specific gems
COPY --chown=${USER_NAME}:${USER_NAME} Gemfile Gemfile.lock ./
RUN gem install bundler \
  && bundle install

# Copy application code
COPY --chown=${USER_NAME}:${USER_NAME}  . .
```

## Node

```
FROM tibomogul/rbenv_nvm:user-node

# Install application utility packages
RUN source /home/$USER_NAME/.bashrc \
  && npm install -g ember-cli@3.24

# Install application-specific packages
COPY --chown=${USER_NAME}:${USER_NAME} package*.json ./
RUN npm install

# Copy application code
COPY --chown=${USER_NAME}:${USER_NAME}  . .
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
