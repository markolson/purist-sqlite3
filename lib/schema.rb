module Sqlite3Table
  class Sqlite_master
    attr_accessor :header
    def initialize(f)
      record = Sqlite3Record.new(f)
      payload = StringIO.new(record.payload)
      @header = {
        :type => Sqlite3Record::read_cell(record.cells[0], payload),
        :name => Sqlite3Record::read_cell(record.cells[1], payload),
        :tbl_name => Sqlite3Record::read_cell(record.cells[2], payload),
        :rootpage => Sqlite3Record::read_cell(record.cells[3], payload),
        :sql => Sqlite3Record::read_cell(record.cells[4], payload)
      }
    end
  end
end