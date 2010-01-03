#!/usr/bin/ruby

require 'lib/header.rb'
require 'lib/btree.rb'



f = File.open('simple.db', 'rb')
header = read_sqlite3_header(f)
root = Sqlite3BTree.new(f)