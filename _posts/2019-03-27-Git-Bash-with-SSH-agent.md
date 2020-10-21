---
published: true
title: Git Bash with SSH agent
tags:
  - shell
  - ssh
  - bash
  - linux
  - windows
  - macos
  - github
  - git
  - agent
  - keys
---
Quick tip for not having to keep typing your SSH key passphrase (which should be a good, difficult passphrase) when executing git commands that access the GitHub remote server.

An SSH "agent" is a program that can run in the background and load up your private key(s), responding on your behalf to prompts for the passphrase.

PuTTY includes the extra program Pageant for this purpose.

Command-line SSH, which is part of Linux and MacOS, and included in Git for Windows, has ssh-agent. The following commands can be executed in your Bash shell to start the agent (and leave it running), and to add your SSH key(s) to the agent. Where you'll type the passphrase just once, then all subsequent (say git) commands won't prompt you again for it:

```shell
eval `ssh-agent.exe`
ssh-add /my/ssh/keyfile.rsa
```

(Notice the back-ticks.)

Or, if you're just using the default keyfile location of $HOME/.ssh/id_rsa, you don't have to specify the file name at all in that second step:
```shell
ssh-add
```
Or, if you want to have Git Bash automatically do this for you when it starts up, see [https://help.github.com/en/articles/working-with-ssh-key-passphrases#auto-launching-ssh-agent-on-git-for-windows](https://help.github.com/en/articles/working-with-ssh-key-passphrases#auto-launching-ssh-agent-on-git-for-windows)