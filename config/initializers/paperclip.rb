Paperclip::interpolates :coursename do |attachment, style|
  attachment.instance.course.eng_name # or whatever you've named your User's login/username/etc. attribute
end

Paperclip::interpolates :courseid do |attachment, style|
  attachment.instance.course.id # or whatever you've named your User's login/username/etc. attribute
end

Paperclip::interpolates :userid do |attachment, style|
  attachment.instance.owner_id # or whatever you've named your User's login/username/etc. attribute
end