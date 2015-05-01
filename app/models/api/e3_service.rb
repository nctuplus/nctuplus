class E3Service 


def self.login(username, password)

		return if not username and not password
require 'open-uri'
require 'net/http'
	sendE3={:key=>Nctuplus::Application.config.secret_key_base ,:id=>username, :pwd=>password}				
	res = Curl.post("#{E3::URL}/Authentication",sendE3).body_str.to_s	
	
	if res=='"OK"'
		return {:e3_auth=>true, :user=>User.where(:student_id=>username).take}
	else
		return {:e3_auth=>false}	
		end
end

def self.get_course(sem)
	sendE3={:acy=>sem.year, :sem=>sem.half} 
	http=Curl.post("#{E3::URL}/CourseList",sendE3)

	return JSON.parse(http.body_str.force_encoding("UTF-8"))
	
end

def self.get_teacher_list
	http=Curl.get("#{E3::URL}/TeacherList",{})
	return JSON.parse(http.body_str.force_encoding("UTF-8"))
end

def self.get_department_list
	http=Curl.post("#{E3::URL}/DepartmentList",{})
	return JSON.parse(http.body_str.force_encoding("UTF-8"))
end	
	
end 
