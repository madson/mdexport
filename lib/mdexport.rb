#!/usr/bin/env ruby

require 'github/markdown'
require 'fileutils'
require 'filewatcher'

class Mdexport
  
  def self.run
    
    folder = nil
    watching = false
    
    if ARGV.size > 0
      
      ARGV.each do |param|
        if param == '-w' || param == '--watch'
          puts 'Watching file changes.'
          watching = true
        end
        
        if folder == nil && File.exist?(param)
          folder = File.expand_path param
        end
      end
      
    end
    
    if folder == nil
      folder = File.expand_path "."
    end
    
    pattern = "#{folder}/**/*.md"

    files = []
    files += Dir[pattern]
    
    if files.size == 0
      puts "There is no markdown files here"
    end
    
    files.each do |file|
      self.process file
    end

    if watching
      FileWatcher.new(pattern).watch do |filename|
        puts "File " + filename + " was changed."
        self.process filename
        
        basename = self.basename filename
        self.refresh_page basename
      end
    end
    
  end
  
  def self.refresh_page keyword
    puts "Refreshing page with keyword: #{keyword}"
    
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
  
  def self.extension file
    File.extname file
  end
  
  def self.basename file
    extension = self.extension file
    File.basename(file, extension)
  end
  
  def self.process( file )

  extension = self.extension file
  basename = self.basename file
  content = File.read file
  html_body = GitHub::Markdown.render_gfm content
  html_title = basename
  html_filename = file.gsub(extension, '.html')

  html_header = <<HEADER
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
<style>
#wiki-wrapper #template blockquote {
  margin: 1em 0;
  border-left: 4px solid #ddd;
  padding-left: .8em;
  color: #555;
}

/*
  gollum.css
  A basic stylesheet for Gollum
*/

/* @section core */
body, html {
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
  font-size: 10px;
  margin: 0;
  padding: 0;
}

#wiki-wrapper {
  margin: 0 auto;
  overflow: visible;
  width: 100%;
}

@media all and (min-width: 940px) {
  #wiki-wrapper {
    max-width: 920px;
    padding-left:20px;
    padding-right:20px;
  }
}

a:link {
  color: #4183c4;
  text-decoration: none;
}

a:hover, a:visited {
  color: #4183c4;
  text-decoration: underline;
}


/* @section head */
#head {
  margin: 1em 0 0;
  padding: 0;
  overflow: hidden;
}

#head h1 {
  font-size: 1.5em;
  float: left;
  line-height: normal;
  margin: 0;
  padding: 0 0 0 0.667em;
}

#head ul.actions {
  clear: both;
  margin: 0 1em;
}

@media all and (min-width: 940px) {
  #head {
    border-bottom: 1px solid #ddd;
    padding-bottom: 0.3em;
    margin: 4em 0 1.5em;
  }

  #head h1 {
    font-size: 2.5em;
    padding: 2px 0 0 0;
  }

  #head ul.actions {
    clear: none;
    float: right;
    margin: 0;
  }
}

/* @section content */
#wiki-content {
  height: 1%;
  overflow: visible;
}

#wiki-content .wrap {
  height: 1%;
  overflow: auto;
}

/* @section comments */
#wiki-body #inline-comment {
  display: none; /* todo */
}

/* @section body */

.has-leftbar #wiki-body {
  float: right;
  clear: right;
}

#wiki-body {
  display: block;
  float: left;
  clear: left;
  margin-right: 3%;
  margin-bottom: 40px;
  width: 100%;
}

#wiki-body table {
  display: block;
  overflow: auto;
  border: 0;
}

.has-sidebar #wiki-body {
  width: 68%;
}

/* @section toc */
#wiki-toc-main {
  background-color: #F7F7F7;
  border: 1px solid #DDD;
  font-size: 13px;
  padding: 0px 5px;
  float: left;
  margin-bottom: 20px;
  min-width: 33%;

  border-radius: 0.5em;
  -moz-border-radius: 0.5em;
  -webkit-border-radius: 0.5em;
}
#wiki-toc-main > div {
  border: none;
}

/* @section sidebar */
.has-leftbar #wiki-sidebar {
  float: left;
}

.has-rightbar #wiki-sidebar {
  float: right;
}

#wiki-sidebar {
  background-color: #f7f7f7;
  border: 1px solid #ddd;
  font-size: 13px;
  padding: 7px;
  width: 25%;
  color: #555;

  border-radius: 0.5em;
  -moz-border-radius: 0.5em;
  -webkit-border-radius: 0.5em;
}

#wiki-sidebar p {
  margin: 13px 0 0;
}

#wiki-sidebar > p:first-child {
  margin-top: 10px;
}

#wiki-sidebar p.parent {
  border-bottom: 1px solid #bbb;
  font-weight: bold;
  margin: 0 0 0.5em 0;
  padding: 0 0 0.5em 0;
  text-shadow: 0 1px 0 #fff;
}

/* Back arrow */
#wiki-sidebar p.parent:before {
  color: #666;
  content: "← ";
}

/* @section footer */

#wiki-footer {
  clear: both;
  margin: 2em 0 5em;
}

.has-sidebar #wiki-footer {
  width: 70%;
}

#wiki-header #header-content,
#wiki-footer #footer-content {
  background-color: #f7f7f7;
  border: 1px solid #ddd;
  padding: 1em;

  border-radius: 0.5em;
  -moz-border-radius: 0.5em;
  -webkit-border-radius: 0.5em;
}
#wiki-header #header-content {
  margin-bottom: 1.5em;
}

#wiki-footer #footer-content {
  margin-top: 1.5em;
}

#wiki-footer #footer-content h3 {
  font-size: 1.2em;
  color: #333;
  margin: 0;
  padding: 0 0 0.2em;
  text-shadow: 0 1px 0 #fff;
}

#wiki-footer #footer-content p {
  margin: 0.5em 0 0;
  padding: 0;
}

#wiki-footer #footer-content ul.links {
  margin: 0.5em 0 0;
  overflow: hidden;
  padding: 0;
}

#wiki-footer #footer-content ul.links li {
  color: #999;
  float: left;
  list-style-position: inside;
  list-style-type: square;
  padding: 0;
  margin-left: 0.75em;
}

#wiki-footer #footer-content ul.links li a {
  font-weight: bold;
  text-shadow: 0 1px 0 #fff;
}

#wiki-footer #footer-content ul.links li:first-child {
  list-style-type: none;
  margin: 0;
}

.ff #wiki-footer #footer-content ul.links li:first-child {
  margin: 0 -0.75em 0 0;
}

/* @section page-footer */
.page #footer {
  clear: both;
  border-top: 1px solid #ddd;
  margin: 1em 0 7em;
}

#footer p#last-edit {
  font-size: .9em;
  line-height: 1.6em;
  color: #999;
  margin: 0.9em 0;
}

#footer p#last-edit span.username {
  font-weight: bold;
}

#footer .actions {
  margin-left: 1em;
}

@media all and (min-width: 940px) {
  #footer .actions {
    margin: 0;
  }
}


/* @section history */
.history h1 {
  color: #999;
  font-weight: normal;
}

.history h1 strong {
  color: #000;
  font-weight: bold;
}

#wiki-history {
  margin: 2em 1em 0 1em;
}

#wiki-history fieldset {
  border: 0;
  margin: 1em 0;
  padding: 0;
}

#wiki-history table, #wiki-history tbody {
  border-collapse: collapse;
  padding: 0;
  margin: 0;
  width: 100%;
}

#wiki-history table tr {
  padding: 0;
  margin: 0;
}

#wiki-history table tr {
  background-color: #ebf2f6;
}

#wiki-history table tr td {
  border-top: 1px solid #c0dce9;
  border-bottom: 1px solid #c0dce9;
  font-size: 1em;
  line-height: 1.6em;
  margin: 0;
  padding: 0.3em 0.7em;
}

#wiki-history table tr td.checkbox {
  width: auto;
  padding: 0 0.2em 0 0;
}

#wiki-history table tr td.checkbox input {
  cursor: pointer;
  display: block;
  padding-right: 0;
  padding-top: 0.4em;
  margin: 0 auto;
  width: 1.2em;
  height: 1.2em;
}

#wiki-history table tr:nth-child(2n),
#wiki-history table tr.alt-row {
  background-color: #f3f7fa;
}

#wiki-history table tr.selected {
  background-color: #ffffea !important;
  z-index: 100;
}

#wiki-history table tr td.commit-name {
  border-left: 0;
}

#wiki-history table tr td.commit-name span.time-elapsed {
  color: #999;
}

#wiki-history table tr td.author {
  width: 20%;
}

#wiki-history table tr td.author a {
  color: #000;
  font-weight: bold;
}

#wiki-history table tr td.author a span.username {
  display: block;
  padding-top: 3px;
}

#wiki-history table tr td img {
  background-color: #fff;
  border: 1px solid #999;
  display: block;
  float: left;
  height: 18px;
  overflow: hidden;
  margin: 0 0.5em 0 0;
  width: 18px;
  padding: 2px;
}

#wiki-history table tr td.commit-name a {
  font-size: 0.9em;
  font-family: 'Monaco', 'Andale Mono', Consolas, 'Courier New', monospace;
  padding: 0 0.2em;
}

.history #footer {
  margin-bottom: 7em;
}

.history #wiki-history ul.actions li,
.history #footer ul.actions li {
  margin: 0 0.6em 0 0;
}

@media all and (min-width: 940px) {
  #wiki-history {
    margin: 2em 0 0 0;
  }

  #wiki-history table tr td {
    border: 1px solid #c0dce9;
    font-size: 1em;
    line-height: 1.6em;
    margin: 0;
    padding: 0.3em 0.7em;
  }

  #wiki-history table tr td.checkbox {
    width: 4em;
    padding: 0.3em;
  }
}


/* @section edit */
.edit h1 {
  color: #999;
  font-weight: normal;
}

.edit h1 strong {
  color: #000;
  font-weight: bold;
}


/* @section search */

.results h1 {
  color: #999;
  font-weight: normal;
}

.results h1 strong {
  color: #000;
  font-weight: bold;
}

.results #results {
  border-bottom: 1px solid #ccc;
  margin-left: 1em;
  margin-right: 1em;
  margin-bottom: 2em;
  padding-bottom: 2em;
}

.results #results ul {
  margin: 2em 0 0 0;
  padding: 0;
}

.results #results ul li {
  list-style: none;
  padding: 0.2em 0;
}

.results #results ul li a {
  word-wrap: break-word;
}

@media all and (min-width: 640px) {
  .results #results ul li {
    font-size: 1.2em;
  }
}

@media all and (min-width: 940px) {
  .results #results {
    margin-left: 0;
    margin-right: 0;
  }

  .results #results ul li {
    list-style: disc;
    list-style-position: outside;
    line-height: 1.6em;
  }
}

.results #results ul li span.count {
  color: #999;
}

.results p#no-results {
  font-size: 1.2em;
  line-height: 1.6em;
  margin-top: 2em;
}

.results #footer ul.actions li {
  margin: 0 1em 0 0;
}


/* @section compare */
.compare h1 {
  color: #999;
  font-weight: normal;
}

.compare h1 strong {
  color: #000;
  font-weight: bold;
}

.compare #compare-content {
  margin-top: 3em;
}

.compare .data {
  border: 1px solid #ddd;
  margin: 1em 0 2em;
  overflow: auto;
}

.compare .data table {
  width: 100%;
}

.compare .data pre {
  margin: 0;
  padding: 0;
}

.compare .data pre div {
  padding: 0 0 0 1em;
}

.compare .data tr td {
  font-family: "Consolas", "Monaco", "Andale Mono", "Courier New", monospace;
  font-size: 1.2em;
  line-height: 1.2em;
  margin: 0;
  padding: 0;
}

.compare .data tr td + td + td {
  width: 100%;
}

.compare .data td.line_numbers {
  background: #f7f7f7;
  border-right: 1px solid #999;
  color: #999;
  padding: 0 0 0 0.5em;
}

.compare #compare-content ul.actions li,
.compare #footer ul.actions li {
  margin-left: 0;
  margin-right: 0.6em;
}

.compare #footer {
  margin-bottom: 7em;
}



/* @control syntax */
.highlight  { background: #ffffff; }
.highlight .c { color: #999988; font-style: italic }
.highlight .err { color: #a61717; background-color: #e3d2d2 }
.highlight .k { font-weight: bold }
.highlight .o { font-weight: bold }
.highlight .cm { color: #999988; font-style: italic }
.highlight .cp { color: #999999; font-weight: bold }
.highlight .c1 { color: #999988; font-style: italic }
.highlight .cs { color: #999999; font-weight: bold; font-style: italic }
.highlight .gd { color: #000000; background-color: #ffdddd }
.highlight .gd .x { color: #000000; background-color: #ffaaaa }
.highlight .ge { font-style: italic }
.highlight .gr { color: #aa0000 }
.highlight .gh { color: #999999 }
.highlight .gi { color: #000000; background-color: #ddffdd }
.highlight .gi .x { color: #000000; background-color: #aaffaa }
.highlight .gc { color: #999; background-color: #EAF2F5 }
.highlight .go { color: #888888 }
.highlight .gp { color: #555555 }
.highlight .gs { font-weight: bold }
.highlight .gu { color: #aaaaaa }
.highlight .gt { color: #aa0000 }


/* @control minibutton */
ul.actions {
   display: block;
   list-style-type: none;
   overflow: hidden;
   padding: 0;
}

 ul.actions li {
   float: left;
   font-size: 0.9em;
   margin-left: 1px;
   margin-bottom: 1px;
 }

.minibutton a {
  background-color: #f7f7f7;
  border: 1px solid #d4d4d4;
  color: #333;
  display: block;
  font-weight: bold;
  margin: 0;
  padding: 0.6em 1em;
  height: 1.4em;

  text-shadow: 0 1px 0 #fff;

  filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0, startColorstr='#f4f4f4', endColorstr='#ececec');
  background: -webkit-gradient(linear, left top, left bottom, from(#f4f4f4), to(#ececec));
  background: -moz-linear-gradient(top, #f4f4f4, #ececec);

  border-radius: 3px;
  -moz-border-radius: 3px;
  -webkit-border-radius: 3px;
}

@media all and (min-width: 940px) {
  ul.actions li {
    margin-left: 0.6em;
    margin-bottom: 0.6em;
  }

  .minibutton a {
    padding: 0.4em 1em;
    height: 1.4em;
  }
}

#search-submit {
  background-color: #f7f7f7;
  border: 1px solid #d4d4d4;
  color: #333;
  display: block;
  font-weight: bold;
  margin: 0;
  padding: 0.4em 1em;

  text-shadow: 0 1px 0 #fff;

  filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0, startColorstr='#f4f4f4', endColorstr='#ececec');
  background: -webkit-gradient(linear, left top, left bottom, from(#f4f4f4), to(#ececec));
  background: -moz-linear-gradient(top, #f4f4f4, #ececec);

  border-radius: 3px;
  -moz-border-radius: 3px;
  -webkit-border-radius: 3px;
}

.minibutton a:hover,
#search-submit:hover {
  background: #3072b3;
  border-color: #518cc6 #518cc6 #2a65a0;
  color: #fff;
  text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.3);
  text-decoration: none;

  filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0, startColorstr='#599bdc', endColorstr='#3072b3');
  background: -webkit-gradient(linear, left top, left bottom, from(#599bdc), to(#3072b3));
  background: -moz-linear-gradient(top, #599bdc, #3072b3);
}

.minibutton a:visited {
  text-decoration: none;
}


/* @special error */
#wiki-wrapper.error {
  height: 1px;
  position: absolute;
  overflow: visible;
  top: 50%;
  width: 100%;
}

#error {
  background-color: #f9f9f9;
  border: 1px solid #e4e4e4;
  left: 50%;
  overflow: hidden;
  padding: 2%;
  margin: -10% 0 0 -35%;
  position: absolute;
  width: 70%;

  border-radius: 0.5em;
  -moz-border-radius: 0.5em;
  -webkit-border-radius: 0.5em;
}

#error h1 {
  font-size: 3em;
  line-height: normal;
  margin: 0;
  padding: 0;
}

#error p {
  font-size: 1.2em;
  line-height: 1.6em;
  margin: 1em 0 0.5em;
  padding: 0;
}


/* @control searchbar */
#head #searchbar {
  float: right;
  padding: 2px 0 0 0;
  overflow: hidden;
}

#head #searchbar #searchbar-fauxtext {
  background: #fff;
  border: 1px solid #d4d4d4;
  overflow: hidden;
  height: 2.2em;

  border-radius: 0.3em;
  -moz-border-radius: 0.3em;
  -webkit-border-radius: 0.3em;
}

#head #searchbar #searchbar-fauxtext input#search-query {
  border: none;
  color: #000;
  float: left;
  font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
  font-size: 1em;
  height: inherit;
  padding: 0 .5em;

  -webkit-focus-ring: none;
}

.ie8 #head #searchbar #searchbar-fauxtext input#search-query {
  padding: 0.5em 0 0 0.5em;
}

#head #searchbar #searchbar-fauxtext input#search-query.ph {
  color: #999;
}

#head #searchbar #searchbar-fauxtext #search-submit {
  border: 0;
  border-left: 1px solid #d4d4d4;
  cursor: pointer;
  margin: 0 !important;
  padding: 0;
  float: right;
  height: inherit;

  border-radius: 0 3px 3px 0;
  -moz-border-radius: 0 3px 3px 0;
  -webkit-border-radius: 0 3px 3px 0;
}

#head #searchbar #searchbar-fauxtext #search-submit span {
  background-image: url(../images/icon-sprite.png);
  background-position: -431px -1px;
  background-repeat: no-repeat;
  display: block;
  height: inherit;
  overflow: hidden;
  text-indent: -5000px;
  width: 32px;
}

.ff #head #searchbar #searchbar-fauxtext #search-submit span,
.ie #head #searchbar #searchbar-fauxtext #search-submit span {
  height: 2.2em;
}

#head #searchbar #searchbar-fauxtext #search-submit:hover span {
  background-position: -431px -28px;
  padding: 0;
}

@media all and (min-width: 940px) {
  #head #searchbar {
    padding: 0;
  }

  #head #searchbar #searchbar-fauxtext #search-submit span {
    width: 28px;
  }

  #head #searchbar #searchbar-fauxtext #search-submit:hover span {
    background-position: -431px -28px;
  }
}

/* @section pages */

#pages {
  font-size: 1.2em;
  margin: 0 1em 20px 1em;
}

@media all and (min-width: 940px) {
  #pages {
    margin: 0 0 20px 0;
  }
}

#pages ul {
    list-style: none;
    margin: 0;
    padding: 0;
}

#pages li a.file,
#pages li a.folder {
    background-image: url(../images/fileview/document.png);
    background-position: 0 1px;
    background-repeat: no-repeat;
    padding-left: 20px;
}

#pages li a.folder {
    background-image: url(../images/fileview/folder-horizontal.png);
}

#pages .breadcrumb {
  border-top: 1px solid #ddd;
  border-bottom: 1px solid #ddd;
  margin: 1em 0;
  padding: 0.25em;
}

.clearfloats {
  clear: both;
}

/*
  Gollum v3 Template
*/

/*!
 *  Font Awesome 4.0.3 by @davegandy - http://fontawesome.io - @fontawesome
 *  License - http://fontawesome.io/license (Font: SIL OFL 1.1, CSS: MIT License)
 */
@font-face {
  font-family: 'FontAwesome';
  src: url('../fonts/fontawesome-webfont.eot?v=4.0.3');
  src: url('../fonts/fontawesome-webfont.eot?#iefix&v=4.0.3') format('embedded-opentype'), url('../fonts/fontawesome-webfont.woff?v=4.0.3') format('woff'), url('../fonts/fontawesome-webfont.ttf?v=4.0.3') format('truetype'), url('../fonts/fontawesome-webfont.svg?v=4.0.3#fontawesomeregular') format('svg');
  font-weight: normal;
  font-style: normal;
}

.fa {
  display: inline-block;
  font: normal normal 16px FontAwesome;
  line-height: 1;
  text-decoration: none;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.fa-link:before {
  content: "\f0c1";
}

.fa-spinner:before {
  content: "\f110";
}

.fa-spin {
  -webkit-animation: spin 2s infinite linear;
  -moz-animation: spin 2s infinite linear;
  -o-animation: spin 2s infinite linear;
  animation: spin 2s infinite linear;
}
@-moz-keyframes spin {
  0% {
    -moz-transform: rotate(0deg);
  }
  100% {
    -moz-transform: rotate(359deg);
  }
}
@-webkit-keyframes spin {
  0% {
    -webkit-transform: rotate(0deg);
  }
  100% {
    -webkit-transform: rotate(359deg);
  }
}
@-o-keyframes spin {
  0% {
    -o-transform: rotate(0deg);
  }
  100% {
    -o-transform: rotate(359deg);
  }
}
@keyframes spin {
  0% {
    -webkit-transform: rotate(0deg);
    transform: rotate(0deg);
  }
  100% {
    -webkit-transform: rotate(359deg);
    transform: rotate(359deg);
  }
}

/* margin & padding reset*/
* {
  margin: 0;
  padding: 0;
}

div {
  display: block;
}

html {
  font-family: sans-serif;
  -ms-text-size-adjust: 100%;
  -webkit-text-size-adjust: 100%;
}

html, body {
  color: #333;
}

body {
  background-color: white;
  font: 13.34px Helvetica, arial, freesans, clean, sans-serif;
  font-size: small;
  line-height: 1.4;
}

img {
  border: 0;
}

a {
  color: #4183C4;
  text-decoration: none;
}

a.absent {
  color: #c00;
}

a:focus {
  outline: thin dotted;
}

a:active, a:hover {
  outline: 0;
}

.markdown-body a.anchor:focus {
  outline: none;
}

.markdown-body a[id].wiki-toc-anchor {
  color: inherit;
  text-decoration: none;
}

.markdown-body {
  padding: 1em;
  font-size: 15px;
  line-height: 1.7;
  overflow: hidden;
  word-wrap: break-word;
}

@media all and (min-width: 940px) {
  .markdown-body {
    padding: 30px;
  }
}

.markdown-body > *:first-child {
  margin-top: 0 !important;
}

.markdown-body > *:last-child {
  margin-bottom: 0 !important;
}

.markdown-body a.absent {
  color: #c00;
}

.markdown-body a.anchor {
  display: block;
  padding-right: 6px;
  padding-left: 30px;
  margin-left: -30px;
  cursor: pointer;
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
}

.markdown-body h1,
.markdown-body h2,
.markdown-body h3,
.markdown-body h4,
.markdown-body h5,
.markdown-body h6 {
  margin: 1em 0 15px;
  padding: 0;
  font-weight: bold;
  line-height: 1.7;
  cursor: text;
  position: relative;
  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
}

.markdown-body h1 .fa-link, .markdown-body h2 .fa-link, .markdown-body h3 .fa-link, .markdown-body h4 .fa-link, .markdown-body h5 .fa-link, .markdown-body h6 .fa-link {
  display: none;
  text-decoration: none;
  color: #000;
}

.markdown-body h1:hover a.anchor .fa-link,
.markdown-body h2:hover a.anchor .fa-link,
.markdown-body h3:hover a.anchor .fa-link,
.markdown-body h4:hover a.anchor .fa-link,
.markdown-body h5:hover a.anchor .fa-link,
.markdown-body h6:hover a.anchor .fa-link {
  text-decoration: none;
  line-height: 1;
  padding-left: 8px;
  margin-left: -30px;
  top: 15%;
  display: inline-block;
}

.markdown-body h1 tt,
.markdown-body h1 code,
.markdown-body h2 tt,
.markdown-body h2 code,
.markdown-body h3 tt,
.markdown-body h3 code,
.markdown-body h4 tt,
.markdown-body h4 code,
.markdown-body h5 tt,
.markdown-body h5 code,
.markdown-body h6 tt,
.markdown-body h6 code {
  font-size: inherit;
}

.markdown-body h1 {
  font-size: 2.5em;
  border-bottom: 1px solid #ddd;
  color: #000;
  margin-top: 20px;
  margin-bottom: 10px;
}

.markdown-body h2 {
  font-size: 2em;
  border-bottom: 1px solid #eee;
  color: #000;
}

.markdown-body h3 {
  font-size: 1.5em;
}

.markdown-body h4 {
  font-size: 1.2em;
}

.markdown-body h5 {
  font-size: 1em;
}

.markdown-body h6 {
  color: #777;
  font-size: 1em;
}

.markdown-body p,
.markdown-body blockquote,
.markdown-body ul,
.markdown-body ol,
.markdown-body dl,
.markdown-body table,
.markdown-body pre,
.markdown-body hr {
  margin: 15px 0;
}

.markdown-body li {
  margin: 0px;
}

.markdown-body hr {
  background: transparent url(../images/dirty-shade.png) repeat-x 0 0;
  border: 0 none;
  color: #ccc;
  height: 4px;
  padding: 0;
}

.markdown-body > h1:first-child,
.markdown-body > h2:first-child,
.markdown-body > h3:first-child,
.markdown-body > h4:first-child,
.markdown-body > h5:first-child,
.markdown-body > h6:first-child {
}

.markdown-body h1 + h2 + h3 {
  margin-top: 30px;
}

.markdown-body a:first-child h1,
.markdown-body a:first-child h2,
.markdown-body a:first-child h3,
.markdown-body a:first-child h4,
.markdown-body a:first-child h5,
.markdown-body a:first-child h6 {
  margin-top: 0;
  padding-top: 0;
}

.markdown-body h1 + p,
.markdown-body h2 + p,
.markdown-body h3 + p,
.markdown-body h4 + p,
.markdown-body h5 + p,
.markdown-body h6 + p {
  margin-top: 0;
}

.markdown-body li p.first {
  display: inline-block;
}

.markdown-body ul,
.markdown-body ol {
  padding-left: 30px;
}

.markdown-body dl {
  padding: 0;
}

.markdown-body dl dt {
  font-size: 14px;
  font-weight: bold;
  font-style: italic;
  padding: 0;
  margin: 15px 0 5px;
}

.markdown-body dl dt:first-child {
  padding: 0;
}

.markdown-body dl dt > :first-child {
  margin-top: 0;
}

.markdown-body dl dt > :last-child {
  margin-bottom: 0;
}

.markdown-body dl dd {
  margin: 0 0 15px;
  padding: 0 15px;
}

.markdown-body dl dd > :first-child {
  margin-top: 0;
}

.markdown-body dl dd > :last-child {
  margin-bottom: 0;
}

.markdown-body blockquote {
  border-left: 4px solid #DDD;
  padding: 0 15px;
  color: #777;
}

.markdown-body blockquote > :first-child {
  margin-top: 0;
}

.markdown-body blockquote > :last-child {
  margin-bottom: 0;
}

.markdown-body table {
  padding: 0;
  border-collapse: collapse;
  border-spacing: 0;
}

.markdown-body table tr {
  border-top: 1px solid #ccc;
  background-color: #fff;
  margin: 0;
  padding: 0;
}

.markdown-body table tr:nth-child(2n) {
  background-color: #f8f8f8;
}

.markdown-body table tr th {
  font-weight: bold;
}

.markdown-body table tr th,
.markdown-body table tr td {
  border: 1px solid #ccc;
  text-align: none;
  margin: 0;
  padding: 6px 13px;
}

.markdown-body table tr th > :first-child,
.markdown-body table tr td > :first-child {
  margin-top: 0;
}

.markdown-body table tr th > :last-child,
.markdown-body table tr td > :last-child {
  margin-bottom: 0;
}

.markdown-body img {
  max-width: 100%;
}

.markdown-body span.frame {
  display: block;
  overflow: hidden;
}

.markdown-body span.frame > span {
  border: 1px solid #ddd;
  display: block;
  float: left;
  overflow: hidden;
  margin: 13px 0 0;
  padding: 7px;
  width: auto;
}

.markdown-body span.frame span img {
  display: block;
  float: left;
}

.markdown-body span.frame span span {
  clear: both;
  color: #333;
  display: block;
  padding: 5px 0 0;
}

.markdown-body span.align-center {
  display: block;
  overflow: hidden;
  clear: both;
}

.markdown-body span.align-center > span {
  display: block;
  overflow: hidden;
  margin: 13px auto 0;
  text-align: center;
}

.markdown-body span.align-center span img {
  margin: 0 auto;
  text-align: center;
}

.markdown-body span.align-right {
  display: block;
  overflow: hidden;
  clear: both;
}

.markdown-body span.align-right > span {
  display: block;
  overflow: hidden;
  margin: 13px 0 0;
  text-align: right;
}

.markdown-body span.align-right span img {
  margin: 0;
  text-align: right;
}

.markdown-body span.float-left {
  display: block;
  margin-right: 13px;
  overflow: hidden;
  float: left;
}

.markdown-body span.float-left span {
  margin: 13px 0 0;
}

.markdown-body span.float-right {
  display: block;
  margin-left: 13px;
  overflow: hidden;
  float: right;
}

.markdown-body span.float-right > span {
  display: block;
  overflow: hidden;
  margin: 13px auto 0;
  text-align: right;
}

.markdown-body code,
.markdown-body pre,
.markdown-body tt {
  font-family: Consolas, "Liberation Mono", Courier, monospace;
  font-size: 12px;
}

.markdown-body code,
.markdown-body tt {
  margin: 0 2px;
  padding: 0 5px;
  white-space: nowrap;
  border: 1px solid #ddd;
  background-color: #f8f8f8;
  border-radius: 3px;
}

.markdown-body pre > tt,
.markdown-body pre > code {
  margin: 0;
  padding: 0;
  white-space: pre;
  border: none;
  background: transparent;
}

.markdown-body pre {
  background-color: #f8f8f8;
  border: 1px solid #ccc;
  font-size: 13px;
  line-height: 19px;
  overflow: auto;
  padding: 6px 10px;
  border-radius: 3px;
}

.markdown-body pre pre,
.markdown-body pre code,
.markdown-body pre tt {
  background-color: transparent;
  border: none;
}

.markdown-body pre pre {
  margin: 0;
  padding: 0;
}

.toc {
  background-color: #F7F7F7;
  border: 1px solid #ddd;
  padding: 5px 10px;
  margin: 0;
  border-radius: 3px;
}

.toc-title {
  color: #888;
  font-size: 14px;
  line-height: 1.6;
  padding: 2px;
  border-bottom: 1px solid #ddd;
  margin-bottom: 3px;
}

.toc ul {
  padding-left: 10px;
  margin: 0;
}

.toc > ul {
  margin-left: 10px;
  font-size: 17px;
}

.toc ul ul {
  font-size: 15px;
}

.toc ul ul ul {
  font-size: 14px;
}

.toc ul li {
  margin: 0;
}

#header-content .toc,
#footer-content .toc,
#sidebar-content .toc {
  border: none;
}

.highlight {
  background: #fff;
}

.highlight .c {
  color: #998;
  font-style: italic;
}

.highlight .err {
  color: #a61717;
  background-color: #e3d2d2;
}

.highlight .k {
  font-weight: bold;
}

.highlight .o {
  font-weight: bold;
}

.highlight .cm {
  color: #998;
  font-style: italic;
}

.highlight .cp {
  color: #999;
  font-weight: bold;
}

.highlight .c1 {
  color: #998;
  font-style: italic;
}

.highlight .cs {
  color: #999;
  font-weight: bold;
  font-style: italic;
}

.highlight .gd {
  color: #000;
  background-color: #fdd;
}

.highlight .gd .x {
  color: #000;
  background-color: #faa;
}

.highlight .ge {
  font-style: italic;
}

.highlight .gr {
  color: #a00;
}

.highlight .gh {
  color: #999;
}

.highlight .gi {
  color: #000;
  background-color: #dfd;
}

.highlight .gi .x {
  color: #000;
  background-color: #afa;
}

.highlight .go {
  color: #888;
}

.highlight .gp {
  color: #555;
}

.highlight .gs {
  font-weight: bold;
}

.highlight .gu {
  color: #800080;
  font-weight: bold;
}

.highlight .gt {
  color: #a00;
}

.highlight .kc {
  font-weight: bold;
}

.highlight .kd {
  font-weight: bold;
}

.highlight .kn {
  font-weight: bold;
}

.highlight .kp {
  font-weight: bold;
}

.highlight .kr {
  font-weight: bold;
}

.highlight .kt {
  color: #458;
  font-weight: bold;
}

.highlight .m {
  color: #099;
}

.highlight .s {
  color: #d14;
}

.highlight .na {
  color: #008080;
}

.highlight .nb {
  color: #0086B3;
}

.highlight .nc {
  color: #458;
  font-weight: bold;
}

.highlight .no {
  color: #008080;
}

.highlight .ni {
  color: #800080;
}

.highlight .ne {
  color: #900;
  font-weight: bold;
}

.highlight .nf {
  color: #900;
  font-weight: bold;
}

.highlight .nn {
  color: #555;
}

.highlight .nt {
  color: #000080;
}

.highlight .nv {
  color: #008080;
}

.highlight .ow {
  font-weight: bold;
}

.highlight .w {
  color: #bbb;
}

.highlight .mf {
  color: #099;
}

.highlight .mh {
  color: #099;
}

.highlight .mi {
  color: #099;
}

.highlight .mo {
  color: #099;
}

.highlight .sb {
  color: #d14;
}

.highlight .sc {
  color: #d14;
}

.highlight .sd {
  color: #d14;
}

.highlight .s2 {
  color: #d14;
}

.highlight .se {
  color: #d14;
}

.highlight .sh {
  color: #d14;
}

.highlight .si {
  color: #d14;
}

.highlight .sx {
  color: #d14;
}

.highlight .sr {
  color: #009926;
}

.highlight .s1 {
  color: #d14;
}

.highlight .ss {
  color: #990073;
}

.highlight .bp {
  color: #999;
}

.highlight .vc {
  color: #008080;
}

.highlight .vg {
  color: #008080;
}

.highlight .vi {
  color: #008080;
}

.highlight .il {
  color: #099;
}

.highlight .gc {
  color: #999;
  background-color: #EAF2F5;
}

.type-csharp .highlight .k {
  color: #00F;
}

.type-csharp .highlight .kt {
  color: #00F;
}

.type-csharp .highlight .nf {
  color: #000;
  font-weight: normal;
}

.type-csharp .highlight .nc {
  color: #2B91AF;
}

.type-csharp .highlight .nn {
  color: #000;
}

.type-csharp .highlight .s {
  color: #A31515;
}

.type-csharp .highlight .sc {
  color: #A31515;
}


</style>
<title>#{html_title}</title>

</head>
<body class="webkit">

<div id="wiki-wrapper" class="page">
  <div id="wiki-content">
    <div class="">
      <div id="wiki-body" class="gollum-markdown-content">
      <div class="markdown-body">
HEADER

  html_footer = <<FOOTER
      </div>
      </div>
    </div>
  </div>
</div>
  
</body>
</html>
FOOTER

  html_content = html_header + html_body + html_footer
  FileUtils.rm(html_filename) if File.exist?(html_filename)
  File.write(html_filename, html_content)

  end # end def

end # end class
