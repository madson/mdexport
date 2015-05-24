#!/usr/bin/env ruby

require 'github/markdown'
require 'fileutils'

class Mdexport
  def self.run

files = []
files += Dir["*.md"]
files += Dir["*.markdown"]

if files.size == 0
  puts "There is no markdown files here"
end

output_dir = "html_files"

files.each do |file|

  extension = File.extname(file)
  basename = File.basename(file, extension)
  content = File.read file
  html_body = GitHub::Markdown.render_gfm content
  html_title = basename
  html_filename = output_dir + "/" + basename + ".html"

  html_header = <<HEADER
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
<style>
h1,
h2,
h3,
h4,
h5,
h6,
p,
blockquote {
    margin: 0;
    padding: 0;
}
body {
    font-family: "Helvetica Neue", Helvetica, "Hiragino Sans GB", Arial, sans-serif;
    font-size: 13px;
    line-height: 18px;
    color: #737373;
    background-color: white;
    margin: 10px 13px 10px 13px;
}
table {
  margin: 10px 0 15px 0;
  border-collapse: collapse;
}
td,th { 
  border: 1px solid #ddd;
  padding: 3px 10px;
}
th {
  padding: 5px 10px;  
}

a {
    color: #0069d6;
}
a:hover {
    color: #0050a3;
    text-decoration: none;
}
a img {
    border: none;
}
p {
    margin-bottom: 9px;
}
h1,
h2,
h3,
h4,
h5,
h6 {
    color: #404040;
    line-height: 36px;
}
h1 {
    margin-bottom: 18px;
    font-size: 30px;
}
h2 {
    font-size: 24px;
}
h3 {
    font-size: 18px;
}
h4 {
    font-size: 16px;
}
h5 {
    font-size: 14px;
}
h6 {
    font-size: 13px;
}
hr {
    margin: 0 0 19px;
    border: 0;
    border-bottom: 1px solid #ccc;
}
blockquote {
    padding: 13px 13px 21px 15px;
    margin-bottom: 18px;
    font-family:georgia,serif;
    font-style: italic;
}
blockquote:before {
    content:"\201C";
    font-size:40px;
    margin-left:-10px;
    font-family:georgia,serif;
    color:#eee;
}
blockquote p {
    font-size: 14px;
    font-weight: 300;
    line-height: 18px;
    margin-bottom: 0;
    font-style: italic;
}
code, pre {
    font-family: Monaco, Andale Mono, Courier New, monospace;
}
code {
    background-color: #fee9cc;
    color: rgba(0, 0, 0, 0.75);
    padding: 1px 3px;
    font-size: 12px;
    -webkit-border-radius: 3px;
    -moz-border-radius: 3px;
    border-radius: 3px;
}
pre {
    display: block;
    padding: 14px;
    margin: 0 0 18px;
    line-height: 16px;
    font-size: 11px;
    border: 1px solid #d9d9d9;
    white-space: pre-wrap;
    word-wrap: break-word;
}
pre code {
    background-color: #fff;
    color:#737373;
    font-size: 11px;
    padding: 0;
}
sup {
    font-size: 0.83em;
    vertical-align: super;
    line-height: 0;
}
* {
  -webkit-print-color-adjust: exact;
}
@media screen and (min-width: 914px) {
    body {
        width: 854px;
        margin:10px auto;
    }
}
@media print {
  body,code,pre code,h1,h2,h3,h4,h5,h6 {
    color: black;
  }
  table, pre {
    page-break-inside: avoid;
  }
}
</style>
<title>#{html_title}</title>

</head>
<body>
HEADER

  html_footer = <<FOOTER
</body>
</html>
FOOTER

  html_content = html_header + html_body + html_footer
  FileUtils.mkdir(output_dir) unless File.exist?(output_dir)
  FileUtils.rm(html_filename) if File.exist?(html_filename)
  File.write(html_filename, html_content)

end # end files.each

  end # end def

end # end class
