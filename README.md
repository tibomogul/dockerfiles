# dockerfiles
Repository for Dockerfiles shared with the world. Hope you find this helpful.

# usage

```
RUN mkdir -p /home/${USERNAME}/.ssh/
RUN echo "Host bitbucket.org\n\tStrictHostKeyChecking no\n" >> /home/${USERNAME}/.ssh/config
RUN chmod 600 /home/${USERNAME}/.ssh/config
```


```
FROM whatever-name-i-give-it

ARG USER_NAME=user
ARG APP_DIR=app
ARG BUNDLER_VERSION=2.5.1

# Install application utility gems
RUN eval "$(/home/${USERNAME}/.rbenv/bin/rbenv init -)" \
  && gem install foreman mailcatcher

# Install application-specific gems
COPY --chown=${USERNAME}:${USERNAME} Gemfile Gemfile.lock ./
RUN eval "$(/home/${USERNAME}/.rbenv/bin/rbenv init -)" \
  && gem install bundler -v ${BUNDLER_VERSION} \
  && bundle install

# Copy application code
COPY --chown=${USERNAME}:${USERNAME}  . .
```

```
FROM tibomogul/rbenv_nvm:user-node

ARG USER_NAME=node

# Install application utility packages
RUN eval "$(/home/${USERNAME}/.rbenv/bin/rbenv init -)" \
  && npm install -g ember-cli@3.24

# Install application-specific packages
COPY --chown=${USERNAME}:${USERNAME} package*.json ./
RUN npm install

# Copy application code
COPY --chown=${USERNAME}:${USERNAME}  . .
```


# building

```
docker build . -f Dockerfile-rbenv_nvm -t tibomogul/rbenv_nvm
```


```
docker build . \
  --build-arg USER_NAME=node \
  -f Dockerfile-rbenv_nvm \
  -t tibomogul/rbenv_nvm:user-node
```
