class Sqlite3BTree
  attr_accessor :header
  attr_accessor :cells
  
  def initialize(f)
    @file = f
    self.header = parse_header
    @types = {2 => 'Interior Index', 5 => 'Interior table', 10 => 'Leaf Index', 13 => 'Leaf Table'}
    self.cells = parse_cells(self.header[:cells])
  end
  
  def parse_header
    f = @file
    header = {
      :type => f.read(1).unpack('C')[0],
      :offset => f.read(2).unpack('n')[0],
      :cells => f.read(2).unpack('n')[0],
      :content => f.read(2).unpack('n')[0],
      :fragmented_free_bytes => f.read(1).unpack('C')[0]
    }
    header[:rightmost_pointer] = f.read(4).unpack('L')[0] if header[:type] < 10
    
    return header
  end
  
  # jimmy data out of the cell pointer array
  def parse_cells(count)
    f = @file
    cells = []
    1.upto(count) do |x|
      cells << f.read(2).unpack('n')[0]
    end
    return cells
  end
  
  
  
  def inspect
    print "#<Sqlite3BTree:#{@types[header[:type]]}>"
  end
end
