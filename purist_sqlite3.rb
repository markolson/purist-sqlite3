#!/usr/bin/ruby

require 'lib/header.rb'
require 'lib/btree.rb'
require 'lib/record.rb'
require 'lib/table.rb'
require 'lib/varint.rb'
require 'lib/schema.rb'

require 'yaml'
require 'pp'

f = File.open(ARGV[0] || 'twotables.db', 'rb')
$file_header = header = read_sqlite3_header(f)
pages = f.stat.size / header[:page_size]


root = Sqlite3BTree.new(f)
$root = false
@tables = {}
#sqlite_master = Sqlite3Table::Sqlite_master.new(root)
#p sqlite_master
sqlite_master = Sqlite3::Table.new(root, true)
p "sqlite_master"
sqlite_master.rows.each{|row|
  r = {
    :type => Sqlite3Record::read_column(row.columns[0], row.payload),
    :name => Sqlite3Record::read_column(row.columns[1], row.payload),
    :tbl_name => Sqlite3Record::read_column(row.columns[2], row.payload),
    :rootpage => Sqlite3Record::read_column(row.columns[3], row.payload),
    :sql => Sqlite3Record::read_column(row.columns[4], row.payload)
  }
  p r
  @tables[r[:rootpage]] = r[:name] if r[:type] == 'table'
  #@tables[row[:rootpage]] = row[:name] if row[:type] == 'table'
}
$root = true

@tables.each { |k,v|
  next if k == 0
  p "[[[DATA FOR #{v.upcase} (#{k})]]]"
  f.rewind
  f.pos = header[:page_size] * (k-1)
  old_pos = f.pos
  page = Sqlite3BTree.new(f)
  f.pos = old_pos
  us = Sqlite3::Table.new(page)

  us.rows.each{|r|
    row = []
    r.columns.each{|col|
      row << Sqlite3Record::read_column(col, r.payload)
    }
    p row  
  }
}
