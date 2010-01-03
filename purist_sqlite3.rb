#!/usr/bin/ruby

require 'lib/header.rb'
require 'lib/btree.rb'
require 'lib/record.rb'
require 'lib/schema.rb'
require 'lib/varint.rb'

require 'yaml'

f = File.open('simple.db', 'rb')
header = read_sqlite3_header(f)
root = Sqlite3BTree.new(f)
old_pos = f.pos

root.cells.each{|cell|
  f.pos = old_pos
  p "schema at #{cell}"
  f.seek(cell) #jump to the schema definition
  schema = Sqlite3Table::Sqlite_master.new(f)
  p schema.header
}
