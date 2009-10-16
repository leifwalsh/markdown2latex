#!/usr/bin/ruby

#class MDSyntaxError < Exception; end

class Block
  def parse text
    # convert *text* and _text_ and such
    text.join "\n"
  end
end

class Paragraph < Block
  def initialize source
    @tex = parse source
  end

  def tolatex
    @tex + "\n\n"
  end
end

class Header < Block
  def initialize level, source
    @innertex = parse [source]
    @level = level
  end

  def tolatex
    if (1..3).include? @level
      "\\#{'sub' * (@level - 1)}section*{#{@innertex}}"
    else
      "\\textbf{#{@innertex}}"
    end
  end
end

class Markdown
  def initialize source
    @source = source
  end

  def parseall source
    current_block = []
    lineno = 0
    source.each_line do |line|
      lineno += 1
      line.chomp!
      case line
      when /^=+/
        raise SyntaxError::new "line #{lineno}" if current_block.length != 1
        yield Header::new 1, current_block[0]
        current_block = []
      when /^-+/
        raise SyntaxError::new "line #{lineno}" if current_block.length != 1
        yield Header::new 2, current_block[0]
        current_block = []
      when /^(\#+)\s+(.*)$/
        yield Paragraph::new current_block
        yield Header::new($~[1].length, ($~[2].sub /\s+\#+$/, ''))
        current_block = []
      when ""
        yield Paragraph::new current_block
        current_block = []
      else
        current_block << line
      end
    end
  end

  def tolatex
    parseall(@source) { |elt| yield elt.tolatex }
  end
end

def main
  md = Markdown::new ARGF.read
  md.tolatex { |piece| puts piece }
end

main
