# dockerfiles
Repository for Dockerfiles shared with the world. Hope you find this helpful.

# sample usage

## Ruby

```
FROM tibomogul/rbenv_nvm

ARG USER_NAME=user
ARG APP_DIR=app
ARG BUNDLER_VERSION=2.5.1

# Install application utility gems
RUN eval "$(/home/${USER_NAME}/.rbenv/bin/rbenv init -)" \
  && gem install foreman mailcatcher

# Install application-specific gems
COPY --chown=${USER_NAME}:${USER_NAME} Gemfile Gemfile.lock ./
RUN eval "$(/home/${USER_NAME}/.rbenv/bin/rbenv init -)" \
  && gem install bundler -v ${BUNDLER_VERSION} \
  && bundle install

# Copy application code
COPY --chown=${USER_NAME}:${USER_NAME}  . .
```

## Node

```
FROM tibomogul/rbenv_nvm:user-node

ARG USER_NAME=node

# Install application utility packages
RUN eval "$(/home/${USER_NAME}/.rbenv/bin/rbenv init -)" \
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
