# Container file for building node projects

This Containerfile setups a secure node environment and installs the dependencies.

Features:
- Setup a secure environment with a new user and group with an id of 10001
    - Prevent jailbreaking as a privileged user including a user with sudo
- Support private git repos via SSH agent

## Usage

```dockerfile
FROM ghcr.io/jrschumacher/containerfile-nodebuild:18-alpine as node-setup

COPY package.json package-lock.json ./

RUN --mount=type=ssh,uid=10001 npm ci

FROM node-setup as builder

COPY . .

RUN npm run build

FROM builder as runner

CMD ["npm", "start"]
```