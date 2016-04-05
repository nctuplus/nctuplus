module BookHelper
	
  def contact_way(sale_book)
    case sale_book.contact_way
      when 0 # email
        return sale_book.user.email 
      when 1 # fb
       return link_to("Facebook", sale_book.user.social_webpage_url)
      when 2 # google
       return link_to("Google", sale_book.user.social_webpage_url)
    end
  
  end
end
