#!/usr/bin/env ruby
require 'fileutils'

if (ARGV[0] == "--help")
    puts "Usage: ruby QTProcessor.rb"
    exit
end

puts 'Enter directory name: '
directory_to_modify = STDIN.gets.chomp

if(!Dir.exists?(directory_to_modify))
    puts 'ERROR: Directory ' + directory_to_modify + ' does not exist.'
    exit
end

Dir.glob(directory_to_modify+'/*.qt') do |qt_file|
    original_qt_file = qt_file
    qt_file = qt_file.split('Job_')[1].split('.mp4')[0] + '.qt.text'    # Take after 'Job_' and before '.mp4' then appends '.qt.text'
    File.rename(original_qt_file, directory_to_modify + '/' + qt_file)  # Puts in original directory

    if(File.exist?('template.smil'))
        FileUtils.cp('template.smil', directory_to_modify + '/' + qt_file.split('.qt.text')[0]+'.smil')
    elsif (File.exist?(directory_to_modify + '/template.smil'))
        FileUtils.cp(directory_to_modify + '/' + 'template.smil', directory_to_modify + '/' + qt_file.split('.qt.text')[0]+'.smil')
    else
        puts "ERROR: template.smil not in current or specified working directory."
    end

    Dir.glob(directory_to_modify+'/*.smil') do |smil_file|
        next if smil_file==directory_to_modify + '/' + 'template.smil'
        text = File.read(smil_file)
        new_contents = text.gsub(/\{file\_name\}/, qt_file.split('.qt.text')[0])
        File.open(smil_file, "w") {|file| file.puts new_contents }
    end

end

Dir.glob(directory_to_modify+'/*.text') do |text_file|
    text = File.read(text_file)
    new_contents = text.gsub(/\[(\w+)\]/, '(\1)')    # Matches [BLANK_AUDIO] as well ==> (BLANK_AUDIO)
    new_contents = new_contents.gsub(/.\[\d+\:\d+\:\d+\.\d+\].\(BLANK\_AUDIO\)...\[\d+\:\d+\:\d+\.\d+\]./m, '')
    new_contents = new_contents.gsub(/(\[\d+\:\d+\:\d+\.\d+\])..(\[\d+\:\d+\:\d+\.\d+\])/m, '\2')           # Replace with 2nd group/timestamp
    File.open(text_file, "w") {|file| file.puts new_contents }
end