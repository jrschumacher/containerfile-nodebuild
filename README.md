# Container file for building node projects

This Containerfile setups a secure node environment and installs the dependencies.

Features:
- Setup a secure environment with a new user and group with an id of 10001
    - Prevent jailbreaking as a privileged user including a user with sudo
- Support private git repos via SSH agent