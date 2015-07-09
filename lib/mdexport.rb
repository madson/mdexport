#!/usr/bin/env ruby

require 'filewatcher'
require 'string'
require 'file'
require 'markdown'
require 'mustache'
require 'commander'
require 'rubygems'

class Mdexport
  include Commander::Methods
  
  def run
    program :name, 'mdexport'
    program :version, '0.0.5'
    program :description, 'mdexport is a command line that exports markdown files into html files.'
    
    default_command :run

    command :run do |c|
      c.syntax = 'mdexport [--path /path/to/folder] [--watch] [--clean] [--output /path/to/output_file]'
      c.description = 'Exports the markdown files from folder to html files.'
      c.option '--path STRING', String, 'Path to folder that contains the markdown files.'
      c.option '--output STRING', String, 'Path to output file.'
      c.option '--watch', 'Watch markdown file changes.'
      c.option '--clean', 'Clean html files on folder.'
      c.option '--merge', 'Merge markdown files in a given output file.'
      
      c.action do |args, opt|
        opt.default :path => '.'
        opt.default :output => nil
        opt.default :watch => false
        opt.default :clean => false
        opt.default :merge => false
        
        opt.path = File.expand_path opt.path
        opt.output = File.expand_path opt.output if opt.output

        check_path(opt.path)
        #check_path(opt.output) if opt.output
        
        error "Incompatible params: merge, output." if opt.merge == true && opt.output == nil
        error "Incompatible params: clean, watch." if opt.clean == true && opt.watch == true
        error "Incompatible params: output, watch." if opt.output != nil && opt.watch == true
        
        process opt.path, opt.clean, opt.watch, opt.output, opt.merge
      end
    end

    run!
  end
  
  private
  
  def check_path(path)
    error "Invalid path '#{path}'." unless File.exist?(path)
  end
  
  def error(message)
    puts message; exit 1
  end
    
  def process(path, clean, watch, output, merge)
    extension = clean ? "html" : "md"
    pattern = "#{path}/**/*.#{extension}"

    files = Dir[pattern] || Array.new
    
    if files.size == 0
      type = clean ? "html" : "markdown"
      error "There is no #{type} files to process."
    end

    content = ""

    files.each do |file_path|
      if clean
        File.remove(file_path)
      else
        file_content = File.read(file_path)
        
        if merge
          content += file_content
        else
          content += Markdown.render(file_content)
        end
        
        unless output
          generate_html(content, file_path.html)
          content = ""
        end
      end
    end

    if output != nil
      generate_file(content, output)
    end

    if watch
      FileWatcher.new(pattern).watch do |file_path, event|
        if [:changed, :new].include? event
          file_content = File.read(file_path)
          content = Markdown.render(file_content)
          generate_html(content, file_path.html)
          refresh_page(file_path.basename)
        elsif event.to_sym == :delete
          File.remove(file_path.html)
        end
      end
    end
  end
    
  def refresh_page keyword
    template = File.read("lib/templates/refresh.mustache")
    command = Mustache.render(template, :keyword => keyword)
    system(command)
  end
    
  def generate_html(content, path)
    title = get_title(content) || path.basename
    
    template = File.read("lib/templates/page.mustache")
    content = Mustache.render(template, :title => title, :yield => content)
    
    generate_file(content, path)
  end
  
  def generate_file(content, path)
    File.remove(path)
    File.write(path, content)
  end
  
  def get_title(content)
    title = nil

    if content =~ /<[hH][1-6].*?>(\w.*?)<\/.*?[hH][1-6]>/
      title = Regexp.last_match[1]
    end
    
    title
  end

end # end class
