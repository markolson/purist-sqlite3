module Sqlite3Table
  class Leaf
    attr_accessor :header, :cells
    
    def initialize(node)
      @f = node.file
      @pos = @f.pos
      p "leaf table @ #{@pos}"
      @header = node.header
      @cells = node.cells
    end
    
    def rows
      _internal = []
      @cells.each {|c|
        # I know this is wrong, but I can't be arsed to figure out what I'm doing wrong.
        # I'M IN A HURRY DANGIT
        if (@pos + c) > $file_header[:page_size] + 100
          @f.pos = @pos + c
        else
          @f.pos = @pos
          @f.seek(c)
        end 
        p "row #{c} @ #{@f.pos}"
        record = Sqlite3Record.new(@f)
        _internal << record
      }
      return _internal
    end
  end
end