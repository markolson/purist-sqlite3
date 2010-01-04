def varint(f)
    segments = []
    begin
      msb = f.read(1).unpack('C')[0]
      segments << msb
    end while (msb & 128 == 128)
    # I'm a bad, bad person.
    result = segments.map { |x| [x].pack('C').unpack('B8')[0][1..7] }.join('').to_i(2)
end
