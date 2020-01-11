# Sigma16: makefile
# Copyright (c) 2019 John T. O'Donnell  john.t.odonnell9@gmail.com
# License: GNU GPL Version 3 or later.  Sigma16/LICENSE.txt,NOTICE.txt

# This file is part of Sigma16.  Sigma16 is free software: you can
# redistribute it and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.
# Sigma16 is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.  You should have received
# a copy of the GNU General Public License along with Sigma16.  If
# not, see <https://www.gnu.org/licenses/>.

#-------------------------------------------------------------------------------
# makefile defines commands to run, maintain, and build the system
#-------------------------------------------------------------------------------

# For documentation and to run the app, visit the Sigma16 home page
#   https://jtod.github.io/S16/

# To view or download the source, visit the project page
#   https://github.com/jtod/Sigma16

# Quick reference...
#   make webdev                               prepare S16/dev
#   make release                              prepare S16/releases/...
#   make docs/homepage-index/index.html       index for Sigma16 home page

# Source directories on development computer
#    Sigma/current                               source for entire project
#    Sigma/current/Sigma16                       source for Sigma16
#    Sigma/current/homepage/jtod.github.io/S16   source for github web page

#-------------------------------------------------------------------------------
# How to...

# To upload current development version to web page:
#    cd Sigma/current/Sigma16
#       make webdev
#    cd Sigma/current/homepage/jtod.github.io/S16
#       git status
#       git add ...
#       git commit -m '...commit message...'
#       git push

# To run the development version online:
#       Visit https://jtod.github.io/S16/
#       Click launch development version

#-------------------------------------------------------------------------------
# Define parameters
#-------------------------------------------------------------------------------

# File locations on development machine

# SIGMACURRENT contains several related projects, including Sigma16

SIGMACURRENT:=./..
S16HOME:=$(SIGMACURRENT)/homepage/jtod.github.io/S16/
WEBDEV:=$(S16HOME)/dev

# S16WEBPAGE is a directory in my homepage on github; this is where
# the web release is placed, since users can run the app by clicking a
# link pointing into this area

S16WEBPAGE:=$(SIGMACURRENT)/homepage/jtod.github.io/S16

# Extract the version from the package.json file; it's on the line
# consisting of "version: : "1.2.3".  This defines VERSION, which is
# used for building the top level index and the user guide.

VERSION:=$(shell cat app/package.json | grep version | head -1 | awk -F= "{ print $2 }" | sed 's/[version:,\",]//g' | tr -d '[[:space:]]')

showparams :
	echo SIGMACURRENT = $(SIGMACURRENT)
	echo S16WEBPAGE = $(S16WEBPAGE)
	echo VERSION = $(VERSION).txt
	echo WEBDEV = $(WEBDEV)

#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------

# Build the IDE app
#   make release            build web page for posting on Internet
#   make compile            build executable using npm to compile from source

# Needed to build both web and compiled version
#   make set-version        get version number from package.json
#   make source-dir-index          generate html from markdown source
#   make docs/html/userguide.html          generate html from markdown source
#   make program-indices    index for each directory in programs and examples

# Needed for compilation by npm
#   make dependencies       use npm to download Javascript dependencies
#   make run                run locally
#   make release            make a directory for publication
#   make executable         package up the code into a native executable
#   make move-exe           move the executable into release

#-------------------------------------------------------------------------------
# Files
#-------------------------------------------------------------------------------

# The following files are written by various compilation tools; they
# are not source and shouldn't be edited.  The files marked optional
# are produced when a standalone version is generated, but are not
# necessaryand can be deleted.

#  dist                directory produced by npm (optional)
#  node_modules        directory of packages downloaed by npm (optional)
#  package-lock.json   records package versions; produced by npm (optional)
#  version.js          written by make set-version
#  docs/html            written by make docs

#-------------------------------------------------------------------------------
# Make a release for posting on the web
#-------------------------------------------------------------------------------

# Although JavaScript can be executed directly in a browser, there are
# some files that need to be built.  These include parsing the current
# version number (from package.json), generating the user guide and
# other html pages from markdown source.

# Once the files are all built, the system can be given a release
# number (as a tag) and uploaded to the Sigma16 project page for
# download.  The release itself is then copied to the
# jtod.github.io/Sigma16/releases page for running the app directly
# from the web, without downloading anything.

# (1) Local editing in Sigma/current/Sigma16
#    a. Edit version number in app/package.json
#    b. make release
#    c. git status, git add...
#    d. git commit -m "S16 <release number>"

# (2) Upload to project page for users to download
#    a. Upload to project page: git push origin master
#    b. Visit https://github.com/jtod/Sigma16
#    b. Click New pull request
#    c. Merge the commit and confirm

# (2) Upload executable version In Sigma/current/homepage/jtod.github.io
#    a. Edit S16/index.md to point to the new release
#    b. git status, git add...
#    d. git push origin releases

# (3) On jtod.github.io
#    a. pull: compare master with releases (select releases from dropdown)
#    b. pull request
#    c. merge and confirm

# make homepage-index: Convert index for Sigma16 home page from
# markdown to html.  This should be copied to the git repository for
# jtod.github.io/S16 (make release or make webdev will do that)

docs/homepage-index/index.html : docs/homepage-index/index.md
	pandoc --standalone \
          --template=docs/src/readme-template.html \
          --variable=css:doc.css \
	  --metadata pagetitle="Sigma16 Home Page" \
	  -o docs/homepage-index/index.html \
	  docs/homepage-index/index.md
	cp -up docs/src/doc.css docs/homepage-index

# make release -- create a directory containing the source release of
# the current version.  The app can be launched by clicking a link,
# without needing to download anything.

.PHONY : release
release :
	make set-version
	make source-dir-index
	make docs/homepage-index/index.html
	make docs/html/userguide.html
	make program-indices
	mkdir -p ../release/$(VERSION)
	cp -up ../VERSION ../release/$(VERSION)
	cp -up ../LICENSE.txt ../release/$(VERSION)
	cp -up docs/homepage-index/index.html $(S16HOME)
	cp -up docs/homepage-index/doc.css $(S16HOME)
	cp -up ../index.html ../release/$(VERSION)
	mkdir -p ../release/$(VERSION)/app
	cp -upr datafiles ../release/$(VERSION)/app
	cp -upr docs ../release/$(VERSION)/app
	cp -upr programs ../release/$(VERSION)/app
	cp -up *.html ../release/$(VERSION)/app
	cp -up *.css ../release/$(VERSION)/app
	cp -up *.js ../release/$(VERSION)/app
	cp -up *.json ../release/$(VERSION)/app
	cp -upr  ../release/$(VERSION) $(S16WEBPAGE)/releases

# make webdev -- copy the files to the web page current development directory
# Usage:
#    In project directory:  make webdev
#    In homepage directory: git push

.PHONY : webdev
webdev :
	mkdir -p $(WEBDEV)/app
	make set-version
	cp -up VERSION.txt $(WEBDEV)
	cp -up LICENSE.txt $(WEBDEV)
	make source-dir-index
	cp -up index.html  $(WEBDEV)/app
	make docs/homepage-index/index.html
	cp -up docs/homepage-index/index.html $(S16HOME)
	cp -up docs/homepage-index/doc.css $(S16HOME)
	make docs/html/userguide.html
	cp -upr docs $(WEBDEV)/app
	make program-indices
	cp -upr programs $(WEBDEV)/app
	cp -upr app/datafiles $(WEBDEV)/app
	cp -up app/*.html $(WEBDEV)/app
	cp -up app/*.css $(WEBDEV)/app
	cp -up app/*.js $(WEBDEV)/app

#-------------------------------------------------------------------------------
# Running Sigma16
#-------------------------------------------------------------------------------

# You can run Sigma16 in several ways:

#  (1) Visit the web page jtod.github.io/S16 and click on the link to
#      the latest version.  You need to be connected to the Internet.
#      (If you want the source code, visit jtod.github.io/Sigma16
#      where you can read or download the source, but the app will not
#      run from that location).

#  (2) Download the source files to your local machine and visit
#      index.html in a browser.  You don't need to be connected to the
#      Internet, but a few features won't work: When you open one of
#      the example programs, you need to copy it and paste it into the
#      Editor tab (the button "Copy example to editor" won't work).

#  (3) Download or build the executable compiled for your platform.
#      The app will run faster, it has better ability to save files,
#      and it doesn't need access to the Internet.

#-------------------------------------------------------------------------------
# Notes on workflow for source
#-------------------------------------------------------------------------------

# Local git source repository
#   Sigma/current/Sigma16
# Online source repository
#   https://github.com/jtod/Sigma16
# Online executable location
#   https://jtod.github.io/S16
# Location on Glasgow web server
#   jtod@sibu:/users/staff/jtod/public_html/Sigma16/

# The primary repository for the source code is kept on my local
# machine and github under the project Sigma16.  To make changes to
# the source

# Edit source files in git repository
# make docs/userguide/userguide.html    Reads an auxiliary file to include version nmber
# git status
# git add (files that have been changed)
# git commit 'm "purpose of these changes"

# To change version number

# To advance version number to to v3.0.26 or whatever it is...
# edit package.json     This contains the master definition of version number
# make set-version      Reads package.json and defines two auxiliary files
# make docs/userguide/userguide.html  Need to update version number in the guide
# git tag -a v3.0.26 -m 'move to version v3.0.26'

# To upload new release

# git push origin master

# On github, make a pull request and merge

#-------------------------------------------------------------------------------
# Workflow for online executable version
#-------------------------------------------------------------------------------

# The app won't run directly in the github page: it will show the
# source code but won't render it.  Therefore, to run Sigma16 from the
# web, you need to use the homepage jtod.github.io/S16

# (1) Build the program and upload to project page (as above)

# (2) Copy the source files from the local project repository
#     current/Sigma16 to the version on my homepage, which is
#     current/homeepage/jtod.github.io/S16/releases.  Need to copy the
#     relevant files from the git repository for Sigma16 over to the
#     git repository for jtod.github.io.  Don't copy all files, as
#     these will include library files downloaded by npm for compiling
#     the system.  make copy-app-to-homepage

# (3) Edit homepage/jtod.github.io/S16/index.md to point to the latest
#     release.

# (4) Commit on the releases branch, push, go to github.jtod.io, do a
#     pull request and merge.

#     git push origin release   Try this...
#     git push origin v3.0.27   Try this...



# make compile --- Build everything from just the source.  When publishing
# a release, an option would be to build the documentation (user guide
# and the indexes) so the user wouldn't need to have pandoc installed.

.PHONY : compile
compile :
	make webdev
	make dependencies
	make executable
	make move-executable

# make set-version --- The version number is defined in
# app/package.json; this makefile finds the number there and defines a
# make variable $(VERSION).  This is used in several places, including
# writing a VERSION file in the top directory (not essential but
# helpful for users) and app/version.js (which makes the version
# number available to the JavaScript program).

.PHONY : set-version
set-version :
	echo $(VERSION) > VERSION.txt
	echo "const s16version = \"$(VERSION)\";" > app/version.js


# make program-indices --- Generate the index.html files for the
# programs directory

.PHONY : program-indices
program-indices :
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../docs/src/docstyle.css \
	  --metadata pagetitle="Example programs" \
          -o programs/Examples/index.html \
	  programs/Examples/index.md
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../../docs/src/docstyle.css \
	  --metadata pagetitle="Arithmetic examples" \
          -o programs/Examples/Arithmetic/index.html \
	  programs/Examples/Arithmetic/index.md
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../../docs/src/docstyle.css \
	  --metadata pagetitle="Simple examples" \
          -o programs/Examples/Simple/index.html \
	  programs/Examples/Simple/index.md
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../../docs/src/docstyle.css \
	  --metadata pagetitle="Array examples" \
          -o programs/Examples/Arrays/index.html \
	  programs/Examples/Arrays/index.md
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../../docs/src/docstyle.css \
	  --metadata pagetitle="Interrupt examples" \
          -o programs/Examples/Interrupt/index.html \
	  programs/Examples/Interrupt/index.md
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../../docs/src/docstyle.css \
	  --metadata pagetitle="Data structures" \
          -o programs/Examples/DataStructures/index.html \
	  programs/Examples/DataStructures/index.md
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../../docs/src/docstyle.css \
	  --metadata pagetitle="Input/Output" \
          -o programs/Examples/IO/index.html \
	  programs/Examples/IO/index.md
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../../docs/src/docstyle.css \
	  --metadata pagetitle="Recursion" \
          -o programs/Examples/Recursion/index.html \
	  programs/Examples/Recursion/index.md
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../../docs/src/docstyle.css \
	  --metadata pagetitle="Sorting examples" \
          -o programs/Examples/Sorting/index.html \
	  programs/Examples/Sorting/index.md
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../../docs/src/docstyle.css \
	  --metadata pagetitle="Subroutines" \
          -o programs/Examples/Subroutines/index.html \
	  programs/Examples/Subroutines/index.md
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../../docs/src/docstyle.css \
	  --metadata pagetitle="Testing" \
          -o programs/Examples/Testing/index.html \
	  programs/Examples/Testing/index.md
	pandoc --standalone \
          --template=docs/src/programindex-template.html \
          --variable=css:../../../docs/src/docstyle.css \
	  --metadata pagetitle="Type conversion" \
          -o programs/Examples/TypeConversion/index.html \
	  programs/Examples/TypeConversion/index.md

# make docs/html/userguide.html --- Generate the user guide html file
# from markdown source

docs/html/userguide.html : docs/src/userguide.md docs/src/docstyle.css
	mkdir -p docs/html
	cp -upr docs/src/figures docs/html
	cp -up docs/src/docstyle.css docs/html
	pandoc --standalone \
          --template=docs/src/userguide-template.html \
          --table-of-contents --toc-depth=4 \
          --variable=version:'$(VERSION)' \
          --variable=date:'$(VersionDate)' \
          --variable=css:docstyle.css \
          -o docs/html/userguide.html \
	  docs/src/userguide.md

# make source-dir-index --- Generate index for the project from markdown
# source.

.PHONY : source-dir-index
source-dir-index :
	pandoc --standalone \
          --template=docs/src/readme-template.html \
          --variable=version:'$(VERSION)' \
          --variable=css:'./app/docs/src/docstyle.css' \
          --metadata pagetitle='Sigma16 ${VERSION}' \
	  -o index.html README.md

#-------------------------------------------------------------------------------
# Running as standalone program on local machine with npm
#-------------------------------------------------------------------------------

# Download and install npm
#   https://electronjs.org/docss/tutorial/installation
#   install npm from the electronjs.org web page
# In order to compile a native executable, electron is also needed
#   npm install electron --save-dev       ------ install electron

# Run Sigma16 as a standalone app (independent of a browser)
#   npm install                           ------ download dependencies
#   npm start                             ------ run on local machine

# Compile an executable which will run as standalone app
#   npm run mkdist                        ------ build executable


.PHONY : dependencies
dependencies :
	cd app; npm install

# make run -- run the program on the local computer, without using a
# web page from the Internet.

.PHONY : run
run :
	cd app; npm start


# make executable -- use electron-builder to generate a native
# executable for the current platform.  This allows the program to be
# launched by clicking the executable, and it isn't necessary to have
# npm or the other software tools installed.

.PHONY : executable
executable :
	cd app; npm run mkdist

# make move-exe --- move the executable from dist directory into
# release directory.  There is a bug in Electron-builder: it gives a
# bad name to the exe file; for example it produces 'sigma16
# 3.0.1-7.2.exe' including the quote characters, and if a better name
# is specified using artifactName it fails to expand the variables.
# So in building the release, the executable files are renamed as they
# are moved.

.PHONY : move-executable
move-executable :
	mv app/dist/*.exe release/Sigma16-$(VERSION)-win.exe
