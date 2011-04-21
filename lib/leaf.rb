module Sqlite3Table
  class Leaf
    attr_accessor :header, :cells
    
    def initialize(node, has_parent=true)
      @has_parent = has_parent
      @f = node.file
      @pos = @f.pos
      @header = node.header
      @cells = node.cells
    end
    
    def rows
      _internal = []
      @cells.each {|c|
        @f.pos = @pos
        if @has_parent
          @f.pos += c
        else
          @f.seek(c)
        end
        record = Sqlite3Record.new(@f)
        _internal << record
      }
      return _internal
    end
    
    def verbose_rows
      _rows = []
      rows.each{|r|
        _r = []
        r.columns.each{|col|
          _r << Sqlite3Record::read_column(col, r.payload)
        }
        _rows << _r
      }
      
      _rows
    end
  end
end