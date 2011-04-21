require 'lib/leaf.rb'
require 'lib/inner.rb'

module Sqlite3
  class Table
    
    def initialize(node)
      if(node.header[:type] == 5)
        @t = Sqlite3Table::Inner.new(node)
      else
        @t = Sqlite3Table::Leaf.new(node)
      end
    end
    
    def rows
      @t.rows
    end
    
  end
end