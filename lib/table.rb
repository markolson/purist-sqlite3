require 'lib/leaf.rb'
require 'lib/inner.rb'

module Sqlite3
  class Table
    
    def initialize(node, rootnode=false)
      if(node.header[:type] == 5)
        @t = Sqlite3Table::Inner.new(node)
      else
        @t = Sqlite3Table::Leaf.new(node,!rootnode)
      end
    end
    
    def rows
      @t.rows
    end
    
    def verbose_rows
      @t.verbose_rows if @t.is_a?(Sqlite3Table::Leaf)
    end
    
    def inspect
      @t.inspect
    end
    
  end
end