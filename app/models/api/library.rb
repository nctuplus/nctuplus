class Library

LIB_URL = "http://webpac.lib.nctu.edu.tw/X"
require 'open-uri'
require 'net/http'  

def self.test(search_string, search_type)
	if search_type=="ISBN"
		srch_type = "ISBN"
	else
		srch_type = "WRD"
	end
  data = {"op"=>"find","base"=>"TOP01","request"=>"#{srch_type}=#{search_string}" }

  query_res = Curl.get(LIB_URL, data).body_str
	p query_res
	xml_doc = Nokogiri::XML(query_res)
  set_no = xml_doc.xpath("//set_number")[0].try(:content)

# query by set_no	
	self.search(set_no) if set_no
	
end


private

def self.search(set_no)

  data = {"op"=>"present", 
          "set_no"=>set_no, 
          "set_entry"=>"000000001-000000001", # 取第一筆
          "format"=>"marc"}
  query_res = Curl.get(LIB_URL, data).body_str.to_s	
	p query_res
  xml_doc = Nokogiri::XML(query_res)
  
end


end
