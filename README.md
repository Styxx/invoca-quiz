# Invoca Interview Script

* Developed in [Cloud9.io](c9.io)
* Had some back and forth feedback from the contact at Invoca about D.R.Y. and object-oriented modularity. His comments start with "MRW".
* First time coding a script with just Ruby. It was fun.
* The whole process was very cordial and a good learning experience.
* Without excessive comments, the script is only about 80 lines.

## Usage
```
ruby QTProcessor.rb
```
* Directory you enter is relative directory from where the script currently is.
* Script creates new files in folder `new_files` instead of overwriting/renaming given files (as discussed by e-mail).
* Script modifies all square brackets to parenthesis, regardless of where they are or if supposed to be like that (as discussed by e-mail).
---


### Project Description

We have thousands of video caption (aka subtitle) files in the QuickTime (QT) format that don't work with the video player we want to use.
We need to write a script that will adjust the format of these files so that our player can display them.
A sample file has been attached for you to test with. The changes we need made to each file are:

- Rename each file from this format: Job_XXXX.mp4_5823fb160c8346bc82ec90cc4d4472b1.qt to XXXX.qt.text.
- Generate a file named XXXX.smil for each qt file, that contains the contents of the template.smil file (attached to this email.)
- Replace the "{file_name}" tags in the template file with XXXX when generating the file.
- Replace square brackets that appear in the caption text with parenthesis. 
- Remove caption blocks that only contain the string "[BLANK_AUDIO]".
- Remove the end times on the caption blocks. Each caption consists of a timestamp followed by lines of text, then another timestamp.
  We want the trailing timestamp removed.

Your solution should:
- Be executable on a Mac without special software installed.
- Can we written in any language that meets the above criteria, but Ruby is preferred.
- Take a directory name as an argument. This directory will contain all of the QT files to process.
- Command line tool is preferred, but if you want to make a UI, go for it.