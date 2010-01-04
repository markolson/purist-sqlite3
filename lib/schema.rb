module Sqlite3Table
  class Sqlite_master
    attr_accessor :header, :cells
    
    def initialize(node)
      @f = node.file
      @pos = @f.pos
      @header = node.header
      @cells = node.cells
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
      
      #read the record
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