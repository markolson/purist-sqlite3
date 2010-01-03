def read_sqlite3_header(f)
  check = f.read(16)
  raise "Invalid Magic String" unless (check == "SQLite format 3\000")
  header = {
   :db_size => f.read(2).unpack('n')[0],
   :write_version => f.read(1).unpack('C')[0], #assert == 1
   :read_version => f.read(1).unpack('C')[0],  #assert == 1 
   :reserved => f.read(1).unpack('C')[0],
   :max_payload => f.read(1).unpack('C')[0],   #assert == 64
   :min_payload => f.read(1).unpack('C')[0],   #assert == 32
   :leaf_payload => f.read(1).unpack('C')[0],  #assert == 32
   :change_counter => f.read(4).unpack('N')[0],
   :reserved_1 => f.read(4).unpack('C')[0],    #assert == 0
   :first_freelist => f.read(4).unpack('N')[0],
   :total_freelists => f.read(4).unpack('N')[0],
   :schema_cookie => f.read(4).unpack('N')[0],
   :schema_format => f.read(4).unpack('N')[0],
   :page_cache => f.read(4).unpack('N')[0],
   :max_b_root => f.read(4).unpack('N')[0],    # !0 if no auto-vac
   :text_encoding => f.read(4).unpack('N')[0],
   :user_version => f.read(4).unpack('N')[0],
   :vacuump => f.read(4).unpack('N')[0],
   :reserved_2 => f.read(32).unpack('Z')[0]    #assert == ''
  }
  raise "Invalid Write Version #{header[:write_version]}" unless header[:write_version] == 1
  raise "Invalid Read Version" unless header[:read_version] == 1
  raise "Invalid Maximum embedded payload fraction" unless header[:max_payload] == 64
  raise "Invalid Minimum embedded payload fraction" unless header[:min_payload] == 32
  
  
  return header
end