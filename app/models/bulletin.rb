class Bulletin < ApplicationRecord
	
	belongs_to :user

	def time_out
          if !self.hidden_type
            return false
          elsif self.begin_time > Time.now.utc or self.end_time < Time.now.utc
            return true
          else
            return false
          end
        end

end
