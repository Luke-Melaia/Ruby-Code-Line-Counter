# RCLC
#### Ruby code line counter

An extendable code line counter written in the ruby programming language.

RCLC is able to count: code lines, blank lines, and comment lines in theoretically
any programming/scripting/configuration/markup language.

RCLC uses an array of characters to define whether the line of code
is a comment line or a code line, so it should be able to work with
any language.

## Running the script

1. Get the [main.rb](https://github.com/Luke-Melaia/Ruby-Code-Line-Counter/blob/master/lib/main.rb) script file.
2. Edit the script to scan your project (The script is well documented, so you should be able to figure
it out without too much effort, although, I do go over how to edit it).
3. Execute the script.

## Editing the script

### Defining the project location

Towards the top of the file, under the Project Variables heading - are three global variables
that define the project to scan, and which files to scan.

 - The first variable: `$ProjectName` - defines the name of the project folder.
 - The second variable: `$ProjectSourceFolder` - defines the folder containing all the source code.
 - The third variable: `$ProjectFolder` - defines the path to the project folder (`$ProjectName`)
 
The final variable underneath the Project Variables heading is the full path to the
projects source folder. It's split up into three variables to make switching
projects easier, but you may copy and paste the source folder destination into
the variable if it's easier for you.
 
### Defining the project properties
 
RCLC allows you to configure how the project should be scanned.

That is to say: you define how a comment line will begin,
how a multi-line comment both begins and ends, and what
file extensions to ignore. This allows RCLC to be configured
to scan almost any project, in any just about any language.

 - The first variable: `@@SingleLineComments` - is an array of string literals that define what character(s) a single
line comment begins with. When RCLC finds any line that begins with the character(s) of any of the string literals,
it will count that line as comment.

 - The second variable: `@@MultiLineCommentBegin` - works in much the same way as `@@SingleLineComments`, only it
defines the character(s) that a multi-line comment begins with.

 - The third variable: `@@MultiLineCommentEnd` - defines the character(s) that a mark the end of a multi-line comment.
The string literals in the begin and end variables do **not** have to match, although it looks better if they do.

 - The fourth and final variable: `@@IgnoredFileExtentions` - defines a list of file extensions to ignore.
When RCLC finds a file in the source directory with one of the file extensions in the array, it will pass over
the file rather than scan it.
