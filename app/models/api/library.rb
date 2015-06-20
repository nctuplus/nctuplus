class Library

LIB_URL = "http://webpac.lib.nctu.edu.tw/X"
require 'open-uri'
require 'net/http'  

def self.test(book_name)

  data = {"op"=>"find","base"=>"TOP01","request"=>"WRD=#{book_name}" }

  res = Curl.get(LIB_URL, data).body_str.to_s	
  p res 
end

def self.search(set_no)

  data = {"op"=>"present", 
          "set_no"=>"001383", 
          "set_entry"=>"0000000001-000000003",
          "format"=>"marc"}
  res = Curl.get(LIB_URL, data).body_str.to_s	
  p res
  
end


end
