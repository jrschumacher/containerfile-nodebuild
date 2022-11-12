# syntax=docker/dockerfile:1.2
FROM public.ecr.aws/docker/library/node:18-alpine

# OCI Annotations from https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.maintainer="Ryan Schumacher"                                    \
      org.opencontainers.image.authors="Ryan Schumacher"                                       \
      org.opencontainers.image.title="Node build"                                              \
      org.opencontainers.image.url="https://github.com/jrschumacher/containerfile-nodebuild"   \
      org.opencontainers.image.description="Node builder with ssh agent support"               \
      # SPDX License Expression format;
      org.opencontainers.image.licenses="MIT"                                                  \
      org.opencontainers.image.version="RELEASE"

ARG USER=user
ARG UID=10001
ARG GID=10001

RUN apk update && \
    # Install openssh and git to which are needed to install npm dependencies
    apk add --no-cache \
        openssh-client=9.0_p1-r2 \
        git=2.36.3-r0 && \
    # Force npm version to 8.5.5 to avoid package-lock.json integrity issues with latest npm version
    npm install -g npm@8.5.5 && \
    # Force git via SSH instead of HTTPS
    git config --global url."git@github.com:".insteadOf "https://github.com" && \
    # Create a generic user group
    addgroup --gid "${GID}" "${USER}" && \
    # Add a generic user with a high uid (prevent escaping container as privledged user)
    adduser \
      --disabled-password \
      --gecos "" \
      --home "/home/${USER}" \
      --ingroup "${USER}" \
      --uid "${UID}" \
      "${USER}" && \
    # Add Github to known_hosts
    mkdir -p /home/user/.ssh && \
    chmod 700 /home/user/.ssh && \
    # Copy github's fingerprint to known hosts (prevents git from prompting to approve the fingerprint)
    ssh-keyscan github.com >> /home/user/.ssh/known_hosts

WORKDIR /build

COPY package.json package-lock.json ./

RUN --mount=type=ssh,uid=10001 npm ci

CMD [ "node" ]