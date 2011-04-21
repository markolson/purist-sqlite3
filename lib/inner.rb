module Sqlite3Table
  class Inner
    attr_accessor :header, :cells
    
    def initialize(node)
      @f = node.file
      @pos = @f.pos
      p "inner table @ #{@pos}"
      @header = node.header
      @cells = node.cells
      @children = read_children
    end
    
    def read_children
      kids = []
      @cells.each { |c|
        @f.pos = @pos
        @f.seek(c)
        page_number = @f.read(4).unpack('N')[0]
        int_key = varint(@f)
        @f.pos = page_start = $file_header[:page_size] * page_number
        p "reading child tree @ #{c} // page: #{page_number} // int: #{int_key}"
        
        tree = Sqlite3BTree.new(@f)
        @f.pos = page_start
        t = Sqlite3::Table.new(tree)
        kids << t
      }
      return kids
    end
    
    def rows
      #p @children.first.rows # {|c| c.rows }
      _r = []
      @children.each { |c| 
        p c
        p "----------------"
        _r += c.rows }
      _r
    end
  end
end