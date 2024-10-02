#!/bin/bash

log() {
  local msg="$1"
  local level="$2"  # Can be "INFO", "WARNING", "ERROR"
  
  printf "[%s] %s\n" "$level" "$msg" >&2  # Write to stderr for logs
}

alert() {
  echo "Make sure the image is built with the correct UID and GID."
  echo ""
  echo "Or if you really want to run as root do..."
  echo ""
  exit 1
}

# checkRoot{"Is the current user root?"}
checkRoot() {
  local username=$(whoami)
  if [ "$username" = "root" ]; then
    # abortNotRoot(("Exit Success: proceed to other things"))
    log "Root user, must be non-root!" "ERROR"
    alert
  fi
  return 0
}

# checkUser{"Is USER_NAME defined and existing?"}
checkUser() {
  if [[ -n "${USER_NAME}" ]]; then
    log "USER_NAME defined, ${USER_NAME}" "INFO"
    id "${USER_NAME}" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      log "${USER_NAME} exists" "INFO"
    else
      log "${USER_NAME} does not exist" "ERROR"
      alert
    fi
  else
    # abortUserNotDefined(("Exit Success: Just inform user"))
    log "USER_NAME not defined, exiting" "INFO"
  fi
  return 0
}

# checkEnv{"Are DOCKER_UID and DOCKER_GID defined?"}
checkEnv() {
  if ! [[ -n "${DOCKER_UID}" ]]; then
    # abortEnv(("Exit Error: Inform user these should be provided"))
    log "You need to provide the DOCKER_UID environment variable, exiting." "ERROR"
    alert
  fi
  if ! [[ -n "${DOCKER_GID}" ]]; then
    # abortEnv(("Exit Error: Inform user these should be provided"))
    log "You need to provide the DOCKER_GID environment variable, exiting." "ERROR"
    alert
  fi
  log "DOCKER_UID ${DOCKER_UID}, DOCKER_GID ${DOCKER_GID}" "INFO"
  return 0
}

# checkIds{"Do they match the USER_NAME's uid and gid?"}
checkIds() {
  if [[ "${DOCKER_UID}" = "$(id ${USER_NAME} -u)" ]] && [[ "${DOCKER_GID}" = "$(id ${USER_NAME} -g)" ]]; then
    # abortMatch(("Exit Success"))
    log "IDs match." "INFO"
    return 0
  fi
  log "IDs do not match." "ERROR"
  alert
}

log "Running ENTRYPOINT script to ensure IDs match" "INFO"

checkRoot \
  && checkUser \
  && checkEnv \
  && checkIds

log "Ownership checks succeed, happy coding!" "INFO"

log "Running CMD: $*" "INFO"

exec "${@}"