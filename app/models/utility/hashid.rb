class Hashid

USER_SHARE_ENCODE_SALT = 'nctuplusisgood5566'
USER_SHARE_ENCODE_LENGTH = 8

 def self.user_sharecode_length
    USER_SHARE_ENCODE_LENGTH
 end

 def self.user_share_encode(data) # hash [user_id, semester_id]
    Hashids.new(USER_SHARE_ENCODE_SALT, USER_SHARE_ENCODE_LENGTH).encode(data)
 end
 
 def self.user_share_decode(data)
    result = Hashids.new(USER_SHARE_ENCODE_SALT, USER_SHARE_ENCODE_LENGTH).decode(data)
    if result.try(:size) != 2
	    return nil
	  else	
		  return result
		end
 end


end