class Sqlite3Record
  def self.header_type(x)
    r = case x
      when 0 then nil
      when 1 then '8bit integer'
      when 2 then '16bit integer'
      when 3 then '24bit integer'
      when 4 then '32bit integer'
      when 5 then '48bit integer'
      when 6 then '64bit integer'
      when 7 then 'float'
      when 8 then true
      when 9 then false
    end
    r = "string (#{(x-12)/2})" if (x > 11 && x%2==0)
    r = "blob (#{(x-13)/2})" if (x > 12 && x%2==1)
    return r
  end
  
  def self.read_column(x, payload)
    result = case x
      when 0 then nil
      when 1 then payload.read(1).unpack('c')[0]
      when 2 then payload.read(2).unpack('n')[0]
      when 4 then payload.read(4).unpack('N')[0]
      when 7 then payload.read(8).unpack('G')[0]
      #else print "unknown #{x}"
    end
    if (x > 11 && x%2==0)
      result = payload.read((x-12)/2) #TODO: Correct UTF Encoding
    end
    if (x > 12 && x%2==1)
      result = payload.read((x-13)/2)
    end
    return result
    
  end
  
  attr_accessor :columns, :payload
  def initialize(f)
    payload_length = varint(f)
    rowid = varint(f)
    old_pos = f.pos
    header_length = varint(f) #record length is the first int
    f.pos = old_pos
    header = f.read(header_length)
    # the header length includes itself. reset for now
    payload_io = StringIO.new(header) 
    _ = varint(payload_io) # we already have the length, so skip it
    @columns = []
    while not payload_io.eof?
      @columns << varint(payload_io)
    end
    @payload = StringIO.new(f.read(payload_length - header_length))
  end
end