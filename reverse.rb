require 'css_parser'
require "base64"

include CssParser


parser = CssParser::Parser.new
filename = ARGV.length>=2 ? ARGV[1] : "svg.css"
parser.load_file!(filename)

def sanitizeFilename(arg)
  arg.gsub(/[^A-Za-z0-9\-_]+/m, '')#.gsub(/\.+/m, '(dot)')
end

ctr = 0
html_content="<style>body{background-color:#ffa} \n.previewimg{height:100px;width:100px; border: 1px dotted silver;}</style>"
parser.each_rule_set do |rule_set|
  selector=rule_set.selectors.join("")
  background_image = rule_set['background-image']
  if background_image
    regex_background_dataurl_match = /url\(.*?svg.*?,(.*)\)/m.match(background_image)
    if regex_background_dataurl_match
      svg_content = Base64.decode64( regex_background_dataurl_match[1])
      #filename=('%04i' % ctr) + "_" +sanitizeFilename(selector)+".svg"
      filename=sanitizeFilename(selector)+".svg"
      File.write(filename, svg_content)
      ctr+=1
      html_content+="#{filename} = #{selector}<br/><object type=\"image/svg+xml\" data=\"#{filename}\" class=\"previewimg\"></object><br/>\r\n"
    end
  end
end

File.write("preview.html", html_content)
