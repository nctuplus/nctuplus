class LoginAuth

AUTH_FACEBOOK = 0
AUTH_GOOGLE = 1
AUTH_E3 = 2

AUTH_TYPE_MAX = 3


def initialize(type) 
  _auth_type_e(type)
  @auth_type = type
end


def self.auth_purpose(auth_type, auth_data, current_user)
	case auth_type

	
  end
end


private

def _auth_type_e(type)
  return true if type <= AUTH_TYPE_MAX-1
  raise "ERROR AUTH TYPE"
end

end