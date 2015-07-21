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
	data = Hash.from_xml query_res
  set_no = data["find"]["set_number"]
  return {:status=>false, :message=>"No record"} unless set_no
	doc_number = self.get_doc_number(set_no) 
	return {:status=>false, :message=>"No record"} unless doc_number
	return self.search(doc_number)
	 
end


private

def self.get_doc_number(set_no)
  data = {"op"=>"present", 
          "set_no"=>set_no, 
          "set_entry"=>"000000001-000000001", # 取第一筆
          "format"=>"marc"}
  query_res = Curl.get(LIB_URL, data).body_str.to_s	
	data = Hash.from_xml query_res
  return data["present"]["record"]["doc_number"]
end

def self.search(doc_number) 
	data = {"op"=>"circ-status", 
          "library"=>"TOP01", 
          "sys_no"=>doc_number} # 取第一筆
  query_res = Curl.get(LIB_URL, data).body_str.to_s	
	data = Hash.from_xml query_res
  return data["circ_status"]["item_data"]

end


end# class
