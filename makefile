# Sigma16: makefile
# Copyright (c) 2020 John T. O'Donnell  john.t.odonnell9@gmail.com
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


# Web links
#   Sigma16 home page (link to run the app and documentation)
#     https://jtod.github.io/home/Sigma16/
#   Sigma16 source repository (to download or view the source)
#     https://github.com/jtod/Sigma16

# Source file directories
#   SigmaProject/Sigma16
#   SigmaProject/homepage/jtod.github.io/home/Sigma16

# Building the software
#   Build files: generate docs from source, etc.
#     cd SigmaProject/Sigma16
#     make devversion                               prepare home/Sigma16/dev
#     git status, git add, git commit, git push
#   Make release                              prepare home/Sigma16/releases/...
#     cd SigmaProject/Sigma16
#     Update version in Sigma16/package.json
#     make devversion                               prepare home/Sigma16/dev
#     git status, git add, git commit, git push
#     cd SigmaProject/homepage/jtod.github.io/home/Sigma16
#     edit ...
#     make docs/src/S16homepage/index.html       index for Sigma16 home page
#     git status, git add, git commit, git push

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
#   make example-indices    index for each directory in programs and examples

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
#    a. Edit version number in package.json
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

#-------------------------------------------------------------------------------
# Define parameters
#-------------------------------------------------------------------------------

# Run the makefile from SigmaProject/Sigma16

# Path to parent of the directory containing this makefile
SIGMAPROJECT:=./..

# Source for the Sigma16 Home Page
S16HOMEPAGESOURCE:=$(SIGMAPROJECT)/homepage/jtod.github.io/home/Sigma16
RELEASEDEVELOPMENT:=$(S16HOMEPAGESOURCE)/dev

# S16HOMEPAGE is a directory in my homepage on github; this is where
# the web release is placed, since users can run the app by clicking a
# link pointing into this area

S16HOMEPAGE:=$(SIGMAPROJECT)/homepage/jtod.github.io/S16

# Extract the version from the package.json file; it's on the line
# consisting of "version: : "1.2.3".  This defines VERSION, which is
# used for building the top level index and the user guide.

VERSION:=$(shell cat package.json | grep version | head -1 | awk -F= "{ print $2 }" | sed 's/[version:,\",]//g' | tr -d '[[:space:]]')

# Define dates in several formats, for inclusion in the app and user guide
YEAR=$(shell date +"%Y")
MONTHYEAR=$(shell date +"%B %Y")
MONTHYEARDAY=$(shell date +"%F")

# SIGMAPROJECT         project directory; parent of Sigma16 directory
# S16HOMEPAGE          location of source for the Sigma16 Home Page
# VERSION              version number, found by looking at Sigma16/package.json
# MONTHYEAR            date for display in the gui and in the User Guide
# RELEASEDEVELOPMENT   directory for the release in development

# make showparams - print out the defined values
.PHONY: showparams
showparams:
	echo SIGMAPROJECT = $(SIGMAPROJECT)
	echo S16HOMEPAGE = $(S16HOMEPAGE)
	echo VERSION = $(VERSION).txt
	echo MONTHYEAR = $(MONTHYEAR)
	echo MONTHYEARDAY = $(MONTHYEARDAY)
	echo YEAR = $(YEAR)
	echo RELEASEDEVELOPMENT = $(RELEASEDEVELOPMENT)

#-------------------------------------------------------------------------------
# Homepage index
#-------------------------------------------------------------------------------

# make homepage-index: Convert index for Sigma16 home page from
# markdown to html.  This should be copied to the git repository for
# jtod.github.io/S16 (make release or make devversion will do that)

#          --template=docs/src/readme-template.html \

docs/html/S16homepage/index.html : docs/src/S16homepage/index.md \
	docs/src/S16homepage/homepage.css
	pandoc --standalone \
          --variable=css:homepage.css \
	  --metadata pagetitle="Sigma16 Home Page" \
	  -o docs/html/S16homepage/index.html \
	  docs/src/S16homepage/index.md
	cp -up docs/src/S16homepage/homepage.css docs/html/S16homepage

#-------------------------------------------------------------------------------
# Development version
#-------------------------------------------------------------------------------

# make devversion -- build the documentation files, and copy the files
# to the web page current development directory.  After doing this,
# git status, git add, git commit, git push

# Build files that require preprocessing or compilation from source

.PHONY: build
build:
	make set-version
	make source-dir-index
	make src/js/datafiles/welcome.html
	make example-indices
	make docs/html/S16homepage/index.html
	make docs/html/userguide/userguide.html

# Sigma16 homepage index

.PHONY: homepage-index
homepage-index:
	make docs/html/S16homepage/index.html
	cp -up docs/html/S16homepage/index.html $(S16HOMEPAGESOURCE)
	cp -up docs/src/S16homepage/homepage.css $(S16HOMEPAGESOURCE)

# Make directory containing files for current development version, for
# uploading to the Sigma16 home page.

.PHONY: release-development
release-development:
	mkdir -p $(RELEASEDEVELOPMENT)
	mkdir -p $(RELEASEDEVELOPMENT)/src
	mkdir -p $(RELEASEDEVELOPMENT)/docs
	mkdir -p $(RELEASEDEVELOPMENT)/docs/html
	cp -up VERSION.txt $(RELEASEDEVELOPMENT)
	cp -up LICENSE.txt $(RELEASEDEVELOPMENT)
	cp -upr docs/html/userguide $(RELEASEDEVELOPMENT)/docs/html
	cp -upr examples $(RELEASEDEVELOPMENT)
	cp -upr src/js $(RELEASEDEVELOPMENT)/src

#	mkdir -p $(RELEASEDEVELOPMENT)/src/js
#	cp -up src/js/*.html $(RELEASEDEVELOPMENT)/app
#	cp -up src/js/*.css $(RELEASEDEVELOPMENT)/app
#	cp -up src/js/*.js $(RELEASEDEVELOPMENT)/app
#	cp -up src/js/*.mjs $(RELEASEDEVELOPMENT)/app
#	cp -up index.html  $(RELEASEDEVELOPMENT)/app

# make release -- create a directory containing the source release of
# the current version.  The app can be launched by clicking a link,
# without needing to download anything.  This simply retains the dev
# version in the S16 Home Page, and copies it into releases using the
# VERSION as the folder name.

# When getting ready to make release, before doing the make
# devversion, be sure to check docs/src/S16homepage/index.md.  This
# contains two links to the latest release, one in the "Click to run"
# link and the other in the User Guide link.  Both of these need to be
# updated.

.PHONY : release
release :
	cp -r $(S16HOMEPAGESOURCE)/dev $(S16HOMEPAGESOURCE)/releases/$(VERSION)

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
	make devversion
	make dependencies
	make executable
	make move-executable

#-------------------------------------------------------------------------------
# Version
#-------------------------------------------------------------------------------

# make set-version --- The version number is defined in
# src/js/package.json; this makefile finds the number there and defines a
# make variable $(VERSION).  This is used in several places, including
# writing a VERSION file in the top directory (not essential but
# helpful for users) and src/js/version.js (which makes the version
# number available to the JavaScript program).

.PHONY : set-version
set-version :
	echo $(VERSION) > VERSION.txt
	echo "const s16version = \"$(VERSION)\";" > src/js/version.js


#-------------------------------------------------------------------------------
# Generate index pages for examples
#-------------------------------------------------------------------------------

# make example-indices --- Generate the index.html files for the
# programs directory

.PHONY : example-indices
example-indices :
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Example programs for core architecture" \
          -o examples/index.html \
	  examples/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Example programs for core architecture" \
          -o examples/Core/index.html \
	  examples/Core/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Arithmetic examples" \
          -o examples/Core/Arithmetic/index.html \
	  examples/Core/Arithmetic/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Simple examples" \
          -o examples/Core/Simple/index.html \
	  examples/Core/Simple/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Array examples" \
          -o examples/Core/Arrays/index.html \
	  examples/Core/Arrays/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Example programs for core architecture" \
          -o examples/Advanced/index.html \
	  examples/Advanced/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Interrupt examples" \
          -o examples/Advanced/Interrupt/index.html \
	  examples/Advanced/Interrupt/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Data structures" \
          -o examples/Advanced/DataStructures/index.html \
	  examples/Advanced/DataStructures/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Input/Output" \
          -o examples/Core/IO/index.html \
	  examples/Core/IO/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Recursion" \
          -o examples/Advanced/Recursion/index.html \
	  examples/Advanced/Recursion/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Sorting examples" \
          -o examples/Core/Sorting/index.html \
	  examples/Core/Sorting/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Subroutines" \
          -o examples/Core/Subroutines/index.html \
	  examples/Core/Subroutines/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Testing" \
          -o examples/Advanced/Testing/index.html \
	  examples/Advanced/Testing/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Type conversion" \
          -o examples/Advanced/TypeConversion/index.html \
	  examples/Advanced/TypeConversion/index.md
	pandoc --standalone \
          --template=docs/src/example-indices/exampleindex-template.html \
          --variable=css:../../docs/src/example-indices/exampleindex.css \
	  --metadata pagetitle="Example programs for core architecture" \
          -o examples/SysLib/index.html \
	  examples/SysLib/index.md

src/js/datafiles/welcome.html : src/js/datafiles/srcwelcome.md
	sed "s/VERSION/${VERSION}, ${MONTHYEAR}/g" \
	  src/js/datafiles/srcwelcome.md > src/js/datafiles/welcomeTEMP.md
	pandoc --standalone \
          --template=docs/src/userguide/userguide-template.html \
          --variable=css:../../docs/src/userguide/userguidestyle.css \
          -o src/js/datafiles/welcome.html \
	  src/js/datafiles/welcomeTEMP.md

#-------------------------------------------------------------------------------
# User guide
#-------------------------------------------------------------------------------

# Build user guide html from markdown source

docs/html/userguide/userguide.html : docs/src/userguide/userguide.md \
	  docs/src/userguide/userguide-template.html \
	  docs/src/userguide/userguidestyle.css VERSION.txt
	mkdir -p docs/html/userguide
	cp -upr docs/src/userguide/figures docs/html/userguide
	cp -up docs/src/userguide/userguidestyle.css docs/html/userguide
	pandoc --standalone \
          --template=docs/src/userguide/userguide-template.html \
          --table-of-contents --toc-depth=4 \
          --variable=author:"Copyright $(YEAR) John T. O'Donnell" \
          --variable=date:'Version ${VERSION}, $(MONTHYEAR)' \
          --variable=css:userguidestyle.css \
          -o docs/html/userguide/userguide.html \
	  docs/src/userguide/userguide.md

# make source-dir-index --- Generate index for the project from markdown
# source.

source-dir-index : README.md docs/src/readme/readme.css
	pandoc --standalone \
          --template=docs/src/readme/readme-template.html \
          --variable=version:'$(VERSION), ${MONTHYEAR}' \
          --variable=css:'docs/src/readme/readme.css' \
          --metadata pagetitle='Sigma16 ${VERSION}' \
	  -o index.html README.md

#-------------------------------------------------------------------------------
# The following may be out of date following the revision using express...
#-------------------------------------------------------------------------------

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
	mv src/js/dist/*.exe release/Sigma16-$(VERSION)-win.exe
