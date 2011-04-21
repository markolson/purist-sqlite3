module Sqlite3Table
  class Sqlite_master
    attr_accessor :header, :cells
    
    def initialize(node)
      @f = node.file
      @pos = @f.pos
      p "starting at #{@pos}"
      @header = node.header
      @cells = node.cells
      p @cells
      return self
    end
    
    def rows
      @rows ||= {}
      @cells.each_with_index{ |c,i|
        @rows[c] = get_row(i) unless @rows[c]
      }
      @rows.values
    end
    
    def get_row(row)
      #reset the pointer to the start of the content area on this page
      @f.pos = @pos
      @f.seek(@cells[row])
      p "seeked to #{@cells[row]} from #{@pos}"
      #read the record
      if @header[:type] == 5
        page_number = @f.read(4).unpack('N')[0]

        int_key = varint(@f)
        p "in inner cell #{cells[row]} // #{page_number} // #{int_key}"
        page_start = @f.pos = $file_header[:page_size] * page_number
        
        tree = Sqlite3BTree.new(@f)
        p tree
        tree.cells.each{|c|
          
          row = []
          @f.pos = page_start
          @f.pos += c
          record = Sqlite3Record.new(@f)
          record.columns.each{|col|
            row << Sqlite3Record::read_column(col, record.payload)
          }
          p "row #{c} @ #{@f.pos} "
          p row
        }
        p "!!!!----!!!!!"
        return {:key => 'value'}
      else
        p "[schema] row #{row} @ #{@f.pos} "
        record = Sqlite3Record.new(@f)
        payload = record.payload

        return {
          :type => Sqlite3Record::read_column(record.columns[0], payload),
          :name => Sqlite3Record::read_column(record.columns[1], payload),
          :tbl_name => Sqlite3Record::read_column(record.columns[2], payload),
          :rootpage => Sqlite3Record::read_column(record.columns[3], payload),
          :sql => Sqlite3Record::read_column(record.columns[4], payload)
        }
      end
    end
  end
end