module DiscussHelper

  def sub_disucss_avatar(id="")  
    if current_user.try(:hasSocialAuth?)
      return image_tag(current_user.avatar_url, {size: "45x45", style:"margin-top:10px;", id: id}).html_safe
    else
      return
    end  
  end

end