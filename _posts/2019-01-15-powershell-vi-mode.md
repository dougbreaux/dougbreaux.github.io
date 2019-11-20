---
title: vi edit mode in Windows (10)
tags: [ vi, shell, powershell, windows10, windows, unix ]
---
Small tip if you're on Windows and are used to UNIX vi style shell command history ([set -o vi](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html#The-Set-Builtin)). And aren't using cygwin, [Linux Subsystem for Windows](https://docs.microsoft.com/en-us/windows/wsl/about), Git bash, etc.

Command history search, in particular, is what I really wanted. Searching anywhere in the command, not only at the start, where Windows' F8 search works.

[PowerShell](https://docs.microsoft.com/en-us/powershell/)'s [PSReadLine](https://github.com/lzybkr/PSReadLine) has a vi mode:

`Set-PSReadLineOption -EditMode vi`
