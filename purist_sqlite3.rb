#!/usr/bin/ruby

require 'lib/header.rb'
require 'lib/btree.rb'
require 'lib/record.rb'
require 'lib/schema.rb'
require 'lib/varint.rb'

require 'yaml'

f = File.open(ARGV[0] || 'twotables.db', 'rb')
$file_header = header = read_sqlite3_header(f)
pages = f.stat.size / header[:page_size]
p header

root = Sqlite3BTree.new(f)
@tables = {}
sqlite_master = Sqlite3Table::Sqlite_master.new(root)
p "sqlite_master"
sqlite_master.rows.each{|row|
  @tables[row[:rootpage]] = row[:name] if row[:type] == 'table'
}

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