# Ao3-scraper-cli

## Description

A small personal project to practice scraping and make a little tool to easely read fanfictions from the website [Ao3](https://archiveofourown.org/) in the cli

## Basic plans and guidelines

**those will be set for myself and are subject to change**

### first goals

- [x] main menu works
- [x] search_author works
- [x] select_work(from author)
- [30%] search_tag works
- [70%] select_work works
- [0%] search_work works
- [70%] chapter_select works
- [0%] if oneshot , skips chapter menu 
- [0%] resume_chapter function works
- [0%] read_chapter function works
- [0%] next_chapter function works
- [0%] previous_chapter function works
- [0%] download_chapter function works
- [0%] download_full_work function works
  
### Final goals

- [ ] make a working scraper for the website
- [ ] refactor an add a central menu functin to make it easier to add new features and streamline the code
- [ ] use as little dependencies as possible
- [ ] make it as posix compliant as possible
- [ ] make it easy to use for any OS
- [ ] fzf option would be nice but not gonna work on it till the basic version is done
- **front menu must have those working options** :

>- - [ ] read a fic in terminal
>- - [ ] download a fic as either a txt or epub or pdf (might wanna use zatura for that)
>- - [ ] update the script

- **(R/DL)submenu should have those working options** :

>- - [ ] search for a fic and chapter directly(chapter will always start at 1)(implementing a history of read chapters for each fic would be nice)
>- - [ ] browse for a fic->chapter
>- - [ ] browse for tag->fic->chapter
>- - [50%] browse for author->fic->chapter
>- - [ ] browse for fandom->fic->chapter
