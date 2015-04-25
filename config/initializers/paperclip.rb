Paperclip::interpolates :ct_id do |attachment, style|
  attachment.instance.course_teachership_id 
end

Paperclip::interpolates :user_id do |attachment, style|
  attachment.instance.user_id
end