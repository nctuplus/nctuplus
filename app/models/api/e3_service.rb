class E3Service 


  def self.login(username, password)
    return if username.blank? and password.blank?
    require 'open-uri'
    require 'net/http'
    sendE3={:key=>Nctuplus::Application.config.secret_key_base ,:id=>username, :pwd=>password}				
    res = self._getRawData("Authentication",sendE3)	
    if res=='"OK"' 
      return {:auth=>true, :uid=>username}
    elsif res=='"ERROR"'
      return {:auth=>false, :msg=>  "帳號或密碼錯誤" }	
    else  
      return {:auth=>false, :msg=>  "E3伺服器沒有回應，請暫時利用其他方式登入" }
    end
  end

  def self.getMaterialInfo
    params = {:key=>Nctuplus::Application.config.secret_key_base}
    return _getJsonData("GetMaterialInfo", params)
  end

  def self.getCourse(sem)
    return _getJsonData("CourseList",{:acy=>sem.year, :sem=>sem.half})
  end

  def self.getTeacherList
    return _getJsonData("TeacherList",{})
  end

  def self.getDepartmentList
    return _getJsonData("DepartmentList",{})
  end

  private

  def self._getRawData(url,parameter)
    res = Curl.post("#{E3::URL}/#{url}",parameter) do |curl|
      curl.ssl_verify_peer = false
    end
    return res.body_str
  end

  def self._getJsonData(url,parameter)
    begin 
      return JSON.parse(_getRawData(url,parameter)  )
    rescue JSON::ParserError => e
      InformMailer.course_import("Error Occurred on E3 API!<br> Source:#{url}").deliver
      raise "E3 API Error"
    end
    #return x
  end


end 
