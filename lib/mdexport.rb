#!/usr/bin/env ruby

require 'fileutils'
require 'filewatcher'
require 'string'
require 'markdown'
require 'mustache'

class Mdexport
  
  def self.run
    folder = nil
    watching = false
    cleaning = false
    
    if ARGV.size > 0
      ARGV.each do |param|
        if param == '-w' || param == '--watch'
          puts 'Watching file changes.'
          watching = true
        end
        
        if param == '-c' || param == '--clean'
          puts 'Removing html files.'
          cleaning = true
        end
        
        if folder == nil && File.exist?(param)
          folder = File.expand_path param
        end
      end
    end
    
    unless folder
      folder = File.expand_path "."
    end
    
    pattern = "#{folder}/**/*.md"

    files = Dir[pattern] || Array.new
    
    if files.size == 0
      puts "There is no markdown files here."; exit 1
    end
    
    files.each do |file_path|
      if cleaning
        html_file = file_path.html_file_path
        FileUtils.rm(html_file) if File.exist?(html_file)
      else
        self.generate_html_for(file_path)
      end
    end

    if watching
      FileWatcher.new(pattern).watch do |file_path|
        self.generate_html_for(file_path)
        self.refresh_page(file_path.basename)
      end
    end
  end
    
  def self.refresh_page keyword
    %x{osascript<<ENDGAME
        	tell application "Safari"
          	set windowList to every window
          	repeat with aWindow in windowList
          		set tabList to every tab of aWindow
          		repeat with atab in tabList
          			if (URL of atab contains "#{keyword}") then
          			  tell atab to do javascript "window.location.reload()"
          			end if
          		end repeat
          	end repeat
        	end tell
ENDGAME
}
  end
  
  def self.generate_html_for(file_path)
    file_content = File.read(file_path)
    html_body = Markdown.render(file_content)
    
    title = file_path.basename
    template = File.read("lib/templates/page.mustache")
    content = Mustache.render(template, :title => title, :yield => html_body)

    html_file_path = file_path.html_file_path
    FileUtils.rm(html_file_path) if File.exist?(html_file_path)
    File.write(html_file_path, content)
  end

end # end class
