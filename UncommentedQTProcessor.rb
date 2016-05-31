#!/usr/bin/env ruby
require 'fileutils'

def generate_text_file(old_file, new_name, directory)
    # Read qt_file into memory
    text = File.read(old_file)

    # Regex replacing
    new_contents = text.gsub(/(\[){2}/, '((')                               # Fixes all double brackets              
    new_contents = new_contents.gsub(/(\]){2}/, '))')
    new_contents = new_contents.gsub(/([A-Z]|\))(\])/, '\1)')               # Fixes WORD] or [WORD (single brackets)
    new_contents = new_contents.gsub(/(\[|\()([A-Z]+)/, '(\2')              # Also handles brackets in the middle of the word
    new_contents = new_contents.gsub(/(\[)(\])/, '()')                      # No middle word (optional extra both)
    new_contents = new_contents.gsub(/(\])(\[)/, ')(')                      # Flipped
    new_contents = new_contents.gsub(/(\))(\[)/, ')(')                      # Remaining uneven paren/brackets )[ and ](
    new_contents = new_contents.gsub(/(\[)(\))/, '()')
    new_contents = new_contents.gsub(/.\[\d+\:\d+\:\d+\.\d+\].\(BLANK\_AUDIO\)...\[\d+\:\d+\:\d+\.\d+\]./m, '')  # Get rid of (BLANK_AUDIO) and according whitespace
    new_contents = new_contents.gsub(/(\[\d+\:\d+\:\d+\.\d+\])..(\[\d+\:\d+\:\d+\.\d+\])/m, '\2')                # Remove 1st timestamp, leave 2nd.
    
    # Generate .text file from memory
    new_file = File.open(directory + '/' + new_name, "w")
    new_file.puts new_contents
end

def read_template(directory)
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
    text = template_contents
    qt_file_name = qt_file.split('.qt.text')[0]

    new_contents = text.gsub(/\{file\_name\}/, qt_file_name)                # Replace {file_name}
 
    # Generate smil
    new_file = File.open(directory + '/' + qt_file_name + '.smil', "w")
    new_file.puts new_contents
end

# Main
if (ARGV[0] == "--help")
    puts "Usage: ruby QTProcessor.rb"
    exit
end

puts 'Enter directory name: '
directory_to_modify = STDIN.gets.chomp
new_directory = directory_to_modify + '/new_files'

if(!Dir.exists?(directory_to_modify))
    puts 'ERROR: Directory ' + directory_to_modify + ' does not exist.'
    exit
end

template_contents = read_template(directory_to_modify)              # Store template contents in global var

# Check if new directory exists
if(!Dir.exists?(new_directory))
    Dir.mkdir(new_directory)                                        # Create directory to store new files
end

# For every qt_file: generate text file and generate smil file
Dir.glob(directory_to_modify+'/*.qt') do |qt_file|
    
    new_file_name = qt_file.split('Job_')[1].split('.mp4')[0] + '.qt.text'

    generate_text_file(qt_file, new_file_name, new_directory)
    generate_smil(template_contents, new_file_name, new_directory)
    
end

puts "Done."
