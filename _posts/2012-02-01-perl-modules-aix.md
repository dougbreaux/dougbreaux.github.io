---
title: Perl, Modules, and AIX
tags: [libraries,cpan,modules,perl,aix]
---
I'm sure this information is in hundreds or thousands of other places, but as I had written it up for an internal team Wiki, I thought I'd repost here as well.

[CPAN](http://www.cpan.org/) is the Comprehensive Perl Archive Network. It contains the Perl distributions and source code, Perl documentation, and Perl [add-on Modules](http://www.cpan.org/modules/index.html), among other things.

## AIX

Perl is included by default in AIX, but most of the Modules are not, so the rest of this article deals with installing those.

Some Perl scripts make use of additional Modules, and there are Modules with many different capabilities, so be sure to look for existing Modules if you need to do anything that someone else might have had to do already.

## Obtaining a Module

Again, Modules are obtained from the [CPAN site](http://www.cpan.org/modules/index.html), most likely from the [Search page](http://search.cpan.org/).

For instance, a script we created uses the Date::Simple module. After finding [its page](http://search.cpan.org/%7Eizut/Date-Simple-3.03/lib/Date/Simple.pm), you click the Download link on the right side to obtain what is actually a source package in .tar.gz format.

## Module Installation from Source

These instructions are summarized from somewhere, I thought an earlier version of the [generic installation instructions on the CPAN site](http://www.cpan.org/modules/INSTALL.html). However, that site now describes a simpler approach using a <span style="font-weight: bold;">cpanminus</span> installation module. I'll have to try that out.  

### Decompress the file

This can be done as any user.

```shell
gunzip -c Date-Simple-3.03.tar.gz | tar xvf -
```

### Build the module

These steps can also be performed as any user.

```shell
cd <module-directory>  
perl Makefile.PL noxs  
make  
make test
```

#### noxs

By default, the Makefile will attempt to create an "[XS](http://perldoc.perl.org/perlxs.html)" version of the Module, which means a version that uses native C code to improve performance. This means the "make" command will require access to a local C compiler.

If you don't have a C compiler or want to create a "pure-Perl" Module to copy around to various systems, you use the "noxs" option. The output of "perl Makefile.PL" will actually tell you to use this option if you see errors during the "make" step. If that occurs, the error will look something like:

```shell
cc_r -c -D_ALL_SOURCE -D_ANSI_C_SOURCE -D_POSIX_SOURCE -qmaxmem=-1 -qnoansialias  
 -DUSE_NATIVE_DLOPEN -DNEED_PTHREAD_INIT -q32 -D_LARGE_FILES -qlonglong -O -DVERSION=\"3.03\"  
 -DXS_VERSION=\"3.03\" "-I/usr/opt/perl5/lib/5.8.8/aix-thread-multi/CORE" Simple.c  
/bin/sh: cc_r: not found  
make: The error code from the last command is 127.
```

### Install the module

This step needs to be performed as a user that can write to the Perl installation direction. Most likely "root".

```
make install
```

Also watch for file permissions. By default this could make the module directory, subdirectories, and files be only readable by root.
