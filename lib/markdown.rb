require 'github/markdown'

class Markdown

  def self.render(content)
    GitHub::Markdown.render_gfm(content)
  end
  
end
