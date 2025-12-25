# Building
```
docker build . \
  --build-arg build_docker_uid=$(id -u) \
  --build-arg build_docker_gid=$(id -g) \
  --build-arg build_timezone=Australia/Brisbane \
  -f Dockerfile-langgraph \
  -t tibomogul/langgraph
```

Changing parameters. You can change the following:
- build_user_name (default: user)
- build_app_dir (default: app)
- build_node_version (default: 20.16.0)
- build_nvm_install_version (default: v0.40.0)
- build_ruby_version (default: 3.3.4)
- build_python_version (default: 3.12.3)
- build_timezone (default: Etc/Universal, e.g. Australia/Brisbane)


# Running a named container
Go to a directory that you can use to save your jupyter notebooks.
Put a `.env` file in the directory for any environment variables that you may need.

*This directory is setup to use `tmp` as a folder for saving files, but gitignored so they don't get committed.*

```bash
docker run -it \
  -v ./tmp:/home/user/notebooks \
  -p 8888:8888 \
  -p 2024:2024 \
  -e DOCKER_UID=$(id -u) \
  -e DOCKER_GID=$(id -g) \
  --env-file .env \
  --name langgraph \
  tibomogul/langgraph
```

## Jupyter Lab
Run
```
jupyter lab --ip=0.0.0.0
```

It will output something like this:
```
    To access the server, open this file in a browser:
        file:///home/user/.local/share/jupyter/runtime/jpserver-284-open.html
    Or copy and paste one of these URLs:
        http://ae4864ca024a:8888/lab?token=40dbbd7d2c4bcd0cf827d1dd45f4e1ab83a12bd658b5a812
        http://127.0.0.1:8888/lab?token=40dbbd7d2c4bcd0cf827d1dd45f4e1ab83a12bd658b5a812
```

Copy the paste the URL into your browser's address bar.

## Langgraph Studio
Run
```
langgraph dev --host 0.0.0.0
```
It will output something like this:
```
- 🚀 API: http://0.0.0.0:2024
- 🎨 Studio UI: https://smith.langchain.com/studio/?baseUrl=http://0.0.0.0:2024
- 📚 API Docs: http://0.0.0.0:2024/docs
```
`0.0.0.0` is used so that studio allows connections from the host machine.
Copy the paste the URL into your browser's address bar, but replace `0.0.0.0` with `127.0.0.1`.

# Extras

## Sample 1 using OpenAI
Add your OpenAI Key to the `.env` file.

Run the docker container. Add the following cells:

```ruby
require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "dotenv", require: "dotenv/load"
  gem "ruby-openai"
end
```

```ruby
client = OpenAI::Client.new(access_token: ENV["OPENAI_ACCESS_TOKEN"])
```

```ruby
response = client.chat(
  parameters: {
    model: "gpt-3.5-turbo",
    messages: [{ role: "user", content: "Write a story"}],
    temperature: 0.7,
  }
)
puts response["choices"][0]["message"]["content"]
```

## SSH
If you need SSH access
```
  -v $DOCKER_SSH_AUTH_SOCK:/run/host-services/ssh-auth.sock \
  -e SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock \
```