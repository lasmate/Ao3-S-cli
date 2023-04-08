# Ao3-scraper-cli

## Description

A small personal project to practice scraping and make a little tool to easely read fanfictions from the website [Ao3](https://archiveofourown.org/) in the cli

## Dependencies
    curl   : to make the requests
    fzf    : for menu/input processing
    aria2c : to download the files
## Basic plans and guidelines

**those will be set for myself and are subject to change**

### first goals

- [x] main menu works
- [x] search_author works
- [x] select_work(from author)
- [30%] search_tag works
- [x] select_work works
- [x] select_chapter works
- [0%] search_work works
- [0%] if oneshot skips chapter menu 
- [0%] chapter_resume function works
- [0%] chapter_read function works
- [0%] chapter_next function works
- [0%] chapter_previous function works
- [0%] dl_chapter function works
- [x] dl_work function works
  
### Final goals

- [ ] make a working scraper for the website
- [ ] refactor an add a central menu functin to make it easier to add new features and streamline the code
- use as little dependencies as possible
- make it as posix compliant as possible
- make it easy to use for any OS

- **front menu must have those working options** :

>- - [ ] read a fic in terminal
>- - [x] download a fic as pdf
>- - [ ] update the script

- **(R/DL)submenu should have those working options** :

>- - [ ] search for a fic and chapter directly(chapter will always start at 1)(implementing a history of read chapters for each fic would be nice)
>- - [ ] browse for tag->fic->chapter
>- - [x] browse for author->fic->chapter
>- - [ ] browse for fandom->fic->chapter
