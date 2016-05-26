#
# Copyright (C) 2015 Luke Melaia
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#A simple code line counter.

require 'find'

#Allows easy string replacement
class String
  #Replaces the target string with the replacement string
  def replace(target, replacement)
    return self.gsub target, replacement
  end
end

#Allows me to calculate percentages easily.
class Numeric
  #Returns the percentage of num.
  def percent_of(num)
    (self.to_f / num.to_f * 100).round(2)
  end
end

#############################
#     Project Variables     #
#############################
#Theses variables define what project to scan,
#where the project is located, the source folder
#of the project, and finally, if it should count
#comments at the top of the file as license headers.

#You are free to, and should change these variables
#depending on what project you want to scan.

#I've split the project information up over multiple
#variables so changing the project should be a bit easier.

#The folder name of the project.
$ProjectName = "Series-Freak"
#The source folder name of the project.
$ProjectSourceFolder = "src"
#The folder in which to look for the project.
$ProjectFolder = "C:/Users/Melaia/Documents/NetbeansProjects"

#The full project path. This shouldn't be modified.
$FullProject = "#{$ProjectFolder}/#{$ProjectName}/#{$ProjectSourceFolder}"

#The code line counter class.
class CodeLineCounter
  #############################
  #   Application Constants   #
  #############################
  #These variables define how the script will determine
  #the difference between a code line and comment line,
  #and what files to scan/ignore.
  
  #These variables should only be changed, if you're
  #scanning a project which contains a programming
  #language, that doesn't use a comment style already
  #defined below, or contains non-code files not
  #listed below.

  #What character(s) define a single line comment
  @@SingleLineComments = ["//", "#"]
  
  #What character(s) define the beginning of a multi-line comment
  @@MultiLineCommentBegin = ["/*", "<!--"]
  #What character(s) define the end of a multi-line comment
  @@MultiLineCommentEnd = ["*/", "-->"]
  
  #A list of file extentions to ignore.
  @@IgnoredFileExtentions = [".png"]
  
  #############################
  #   Application Variables   #
  #       DO NOT CHANGE       #
  #############################
  #These variables are used by the application
  #to store information about the project.

  #You should not modify these, the script will
  #return the wrong results if you do.

  #How many files have been scanned.
  @@filesScaned = 0

  #The amount of comments lines
  @@commentLoc = 0
  #The amount of blank lines
  @@blankLoc = 0
  #The amount of code lines
  @@codeLoc = 0
  #The total lines of code.
  @@totalLoc = 0

  #The total size (in bytes) of the project folder structure.
  @@totalBytes = 0
  #The amount of bytes scanned.
  @@bytes = 0
  
  #The last percentage completed computed by the script.
  #This used to ensure that the log doesn't flood with
  #percentage complete messages.
  @@lastPercentage = 0
  
  ####################################
  #   End of Variable Declarations   #
  #     Beginning of Script Logic    #
  ####################################
  
  #Takes in a file path and returns the file extention (e.g. .png).
  #
  #This works by looking for the last "." character in the string,
  #so passing in a directory will return incorrect results.
  def CodeLineCounter.get_file_extention(file_name)
    extention = ""
    
    file_name.reverse.split("").each() do |char|
      if char == "."
        break;
      else
        extention += char
      end
    end
    
    return (extention + ".").reverse
  end
  
  #Walks over all the files in the project tree. 
  #
  #Any file with a file extention in the ignored
  #file extentions list will not be returned (yielded?).
  def CodeLineCounter.walk_project() # :yield: source
    Find.find($FullProject) { |path|
      if !File.directory?(path)
        if !@@IgnoredFileExtentions.include? (get_file_extention(path))
          yield path
        end
      end
    }
  end
  
  #Takes a number and formats it so that
  #it's more readable by placing a character every
  #3 or so numbers.
  def CodeLineCounter.format_number (num)
    return num.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
  end
  
  #Looks through the entire project folder, gets the
  #byte size of each file (that isn't in the ignored list),
  #and adds the byte size to the total byte size variable.
  #
  #This is helpful for displaying a "percentage complete"
  #message to the user. 
  def CodeLineCounter.get_folder_information()
    walk_project do |file|
      fileSize = File.size?(file)
      
      if fileSize != nil
        @@totalBytes += File.size?(file)
      end
    end
  end
  
  #Reads through the file line by line, and increments the
  #line numbers respectively.
  @@brace = false
  def CodeLineCounter.read_file(file)
    if(!File.exist?(file))
      return false
    end
    
    File.foreach(file) do |line|
      line = line.replace(" ", "").replace("\t", "")
      
      if @@brace == true
        if comment_line_end?(line)
          @@commentLoc += 1
          @@brace = false
        else
          @@commentLoc += 1
        end
      elsif comment_line_begin?(line)
        @@commentLoc += 1
        @@brace = true
      elsif blank_line?(line)
        @@blankLoc += 1
      elsif comment_line?(line)
        @@commentLoc += 1
      else
        @@codeLoc += 1
      end
    end
  end
  
  #Is the line a comment line.
  def CodeLineCounter.comment_line?(line)
    @@SingleLineComments.each do |item|
      if line.start_with?(item)
        return true
      end
    end
    return false
  end
  
  #Is the line a blank line
  def CodeLineCounter.blank_line?(line)
    return line.length == 1
  end
  
  #Does a multi-line comment being on this line.
  def CodeLineCounter.comment_line_begin?(line)
    @@MultiLineCommentBegin.each do |item|
      if line.start_with?(item)
        return true
      end
    end
    return false
  end
  
  #Does a multi-line comment end on this line.
  def CodeLineCounter.comment_line_end?(line)
    @@MultiLineCommentEnd.each do |item|
      if line.include?(item)
        return true
      end
    end
    return false
  end
  
  #Scans the entire project and computes the code lines.
  def CodeLineCounter.scan_project
    walk_project do |file|
      read_file file
      @@filesScaned += 1
      
      if(File.size?(file) != nil)
        @@bytes += File.size?(file)
      end
      
      perc = @@bytes.percent_of @@totalBytes
      
      if @@lastPercentage + 1 < perc
        @@lastPercentage = perc
        puts "Percentage Completed: #{perc}%"
      end
    end
  end
  
  #Prints the intro text to the console.
  def CodeLineCounter.print_intro()
    puts "Checking for folder: " + $FullProject + "..."
  
    if File.exist?($FullProject)
      puts "Found folder.\n\n"
    else
      abort "Cound not find folder: " + $FullProject
    end
  end
  
  #Prints the project information to the console.
  def CodeLineCounter.print_info()
    puts "Getting project size...\nThis may take a while depending on the project size."
    get_folder_information()
  
    puts "Project size (in bytes): #{format_number @@totalBytes}\n\n"
  
    puts "Scanning project with options:
Ignored file extentions: #{@@IgnoredFileExtentions}
Single-Line Comments: #{@@SingleLineComments}
Multi-Line Comments: #{@@MultiLineCommentBegin} : #{@@MultiLineCommentEnd}\n\n"
  end
  
  #Starts the scanning process and prints the results to the user.
  def CodeLineCounter.start()
    puts "Scanning project. Please wait...\n\n"
    scan_project
    puts "\nScan completed"
  
    puts "\n--------------------------------------"
    puts "Project Details: \n\n"
    puts "------------------------"
    
    puts "Project size:"
    puts "   #{format_number @@totalBytes} bytes"
    puts "   #{format_number @@totalBytes / 0x400} KB"
    puts "   #{format_number @@totalBytes / 0x400 / 0x400} MB"
    puts "   #{format_number @@totalBytes / 0x400 / 0x400 / 0x400} GB"
    puts "------------------------"
    puts "Lines: "
    puts "   Code Lines: #{format_number @@codeLoc}"
    puts "------------------------"
    puts "   Blank Lines: #{format_number @@blankLoc}"
    puts "------------------------"
    puts "   Comment Lines: #{format_number @@commentLoc}"
    puts "------------------------"
    puts "   Total Lines: #{format_number @@codeLoc + @@blankLoc + @@commentLoc}"
    puts "------------------------"
    
    puts "\nFiles Scaned: #{format_number @@filesScaned}"
    puts "--------------------------------------"
  end
  
  print_intro()
  print_info()
  start()
end
