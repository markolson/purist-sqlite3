#!/usr/bin/ruby

require 'lib/header.rb'
require 'lib/btree.rb'
require 'lib/record.rb'
require 'lib/table.rb'
require 'lib/varint.rb'
require 'lib/schema.rb'

require 'yaml'

f = File.open(ARGV[0] || 'twotables.db', 'rb')
$file_header = header = read_sqlite3_header(f)
pages = f.stat.size / header[:page_size]
p header

root = Sqlite3BTree.new(f)
@tables = {}
#sqlite_master = Sqlite3Table::Sqlite_master.new(root)
sqlite_master = Sqlite3::Table.new(root)
p "sqlite_master"
sqlite_master.rows.each{|row|
  r = {
    :type => Sqlite3Record::read_column(row.columns[0], row.payload),
    :name => Sqlite3Record::read_column(row.columns[1], row.payload),
    :tbl_name => Sqlite3Record::read_column(row.columns[2], row.payload),
    :rootpage => Sqlite3Record::read_column(row.columns[3], row.payload),
    :sql => Sqlite3Record::read_column(row.columns[4], row.payload)
  }
  @tables[r[:rootpage]] = r[:name] if r[:type] == 'table'
}



exit
1.upto(pages-1) {|n|
  p "Rows from #{@tables[n+1]}" if @tables[n+1]
  f.rewind
  f.pos = header[:page_size] * n
  old_pos = f.pos
  page = Sqlite3BTree.new(f)
  next if page.header[:type] != 13 # we can only handle table leaf nodes right now
  page.cells.each{|c|
    f.pos = old_pos
    f.pos += c
    record = Sqlite3Record.new(f)
    row = []
    record.columns.each{|col|
      row << Sqlite3Record::read_column(col, record.payload)
    }
    p row
  }
}