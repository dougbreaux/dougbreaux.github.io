---
published: true
title: Download/Backup Podcast Audio Files
tags:
  - python
  - podcast
  - feed
  - download
  - backup
---
## Simple Python script to download a podcast's audio files

Had a need to backup all the podcast audio files as our church moves from one hosting provider to another, where the former stores all uploaded media files to an Amazon S3 bucket that we can't access directly other than by public, individual file URL.

Turns out there are sufficient Python modules that make this nearly trivial to accomplish, most importantly the [feedparser](https://pypi.org/project/feedparser/) one.

My other requirement was that I wanted to preserve the file dates, so that's the only additional capability of the script.

Script is shared at https://github.com/dougbreaux/podcast-save
