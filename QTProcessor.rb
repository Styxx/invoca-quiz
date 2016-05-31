#!/usr/bin/env ruby
#require 'fileutils'

# Vincent Chang - QT File Processor
# Precondition:     Directory to process is in the same directory as the script.
# =>                template.smil is in the directory specified OR in directory w/ script.
# Postcondition:    Generates files into directory/new_files.
# =>                Does not recursively modify


# MRW General Comments
# 1) It would be easier to read if you broke this code up into functions
# 2) It would be safer to make copies of the "qt" files, rather than modify them in place
# 3) SMIL file generation could be greatly simplified. Read the contents of the QT file into memory, then create files from the in-memory version.
# 4) You missed a requirement to replace all of the square brackets with parenthesis (except for the timestamps, which should keep the square brackets)


# Questions at lines: 79, 110

###############
## FUNCTIONS ##
###############

def generate_text_file(old_file, new_name, directory)
    
    # Read qt_file into memory
    text = File.read(old_file)

    
    # NOTE: I've tried multiple ways to make this more efficient/clean (like using arrays and hashes of regex with blocks)
    # =>    but, unfortunately, all of them failed. If there's a way, please let me know!
    # =>    The regex system could also use refinement, I'm sure.
    # =>    I can string them all together into one line, but I've kept it this way for readability.
    
    # Instead of regexing words, I later decided to regex parenthesis
    # I did this because instead of fixing to always have (WORD), I'm only replacing brackets with parenthesis.
    # Using simple '[' => '(', ']' => ')' did not work, for some reason, so I went with this route
    
    # Regex replacing
    new_contents = text.gsub(/(\[){2}/, '((')                               # Fixes all double brackets              
    new_contents = new_contents.gsub(/(\]){2}/, '))')

    new_contents = new_contents.gsub(/([A-Z]|\))(\])/, '\1)')               # Fixes WORD] or [WORD (single brackets)
    new_contents = new_contents.gsub(/(\[|\()([A-Z]+)/, '(\2')              # Also handles brackets in the middle of the word
    
    new_contents = new_contents.gsub(/(\[)(\])/, '()')                      # No middle word (optional extra both)
    new_contents = new_contents.gsub(/(\])(\[)/, ')(')                      # Flipped
    
    new_contents = new_contents.gsub(/(\))(\[)/, ')(')                      # Remaining uneven paren/brackets )[ and ](
    new_contents = new_contents.gsub(/(\[)(\))/, '()')
    
    new_contents = new_contents.gsub(/.\[\d+\:\d+\:\d+\.\d+\].\(BLANK\_AUDIO\)...\[\d+\:\d+\:\d+\.\d+\]./m, '')             # Get rid of (BLANK_AUDIO) and according whitespace
    new_contents = new_contents.gsub(/(\[\d+\:\d+\:\d+\.\d+\])..(\[\d+\:\d+\:\d+\.\d+\])/m, '\2')                           # Remove 1st timestamp, leave 2nd.
    
    # Generate .text file from memory
    new_file = File.open(directory + '/' + new_name, "w")
    new_file.puts new_contents

    #puts ".text generated"                                      # DEBUG

end

def read_template(directory)

    # MRW: This could be more DRY. Get the path the template file, store it in a var, then use it to do the cp  
    # Find template location and read contents into memory
    if (File.exist?('template.smil'))
        template = File.read('template.smil')
    elsif (File.exist?(directory + '/template.smil'))
        template = File.read(directory + '/template.smil')
    else
        puts "ERROR: template.smil not in current or specified working directory."
    end
        
    return template
end

def generate_smil(template_contents, qt_file, directory)
    
    # QUESTION: Should I just pull directly from template_contents instead of storing in a local var?
    text = template_contents
    qt_file_name = qt_file.split('.qt.text')[0]

    new_contents = text.gsub(/\{file\_name\}/, qt_file_name)                # Replace {file_name}
 
    # Generate smil
    new_file = File.open(directory + '/' + qt_file_name + '.smil', "w")
    new_file.puts new_contents
    
    #puts ".smil generated"                                      # DEBUG
    
end



##########
## MAIN ##
##########

if (ARGV[0] == "--help")
    puts "Usage: ruby QTProcessor.rb"
    exit
end

# Input
puts 'Enter directory name: '
directory_to_modify = STDIN.gets.chomp
new_directory = directory_to_modify + '/new_files'


# QUESTION: Would this be good to put into a separate function, as well?
# Check if directory exists
if(!Dir.exists?(directory_to_modify))
    puts 'ERROR: Directory ' + directory_to_modify + ' does not exist.'
    exit
end
#puts 'Directory ' + directory_to_modify + ' does exist.'

template_contents = read_template(directory_to_modify)              # Store template contents in global var

# Check if new directory exists
if(!Dir.exists?(new_directory))
    Dir.mkdir(new_directory)                                        # Create directory to store new files
end


# DEBUG OUTPUT
#puts 'Files to modify: '
#Dir.glob(directory_to_modify+'/*.qt') do |qt_file|
#    puts qt_file
#end


# For every qt_file: generate text file and generate smil file
Dir.glob(directory_to_modify+'/*.qt') do |qt_file|
    
    new_file_name = qt_file.split('Job_')[1].split('.mp4')[0] + '.qt.text'

    generate_text_file(qt_file, new_file_name, new_directory)
    generate_smil(template_contents, new_file_name, new_directory)
    
end

puts "Done."