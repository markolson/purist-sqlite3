module Sqlite3Table
  class Inner
    attr_accessor :header, :cells
    def initialize(node)
      @f = node.file
      @pos = @f.pos
      @header = node.header
      @cells = node.cells
      
      #@cells << @header[:rightmost_pointer].to_i
      
      
      #print "inner table @ #{@pos} /w cells  "
      #p @cells
      #p @header
      @children = read_children
    end
    
    def read_children
      kids = []
      pages = []
      pages << header[:rightmost_pointer]
      @cells.sort.reverse.each { |c|
        if @pos == 100 then @f.seek(c) else @f.seek(c + @pos) end
        #print "cell #{c} @ #{@f.pos} // #{@pos}"
        page_number = @f.read(4).unpack('N')[0] - 1
        int_key = varint(@f)
        pages << page_number
        #p " points to page #{page_number}"
        @f.seek(@pos)
      }
      pages.sort.each{|page_number|
        @f.pos = $file_header[:page_size] * page_number
        #p "reading child tree @ #{@f.pos} // page: #{page_number}"
        
        tree = Sqlite3BTree.new(@f)
        @f.pos = $file_header[:page_size] * page_number
        t = Sqlite3::Table.new(tree)
        kids << t
      }
      return kids
    end
    
    def rows

      _r = []
      @children.each { |c| 
        #p "getting rows for #{c}"
        _r += c.rows 
        }
      _r
    end
  end
end