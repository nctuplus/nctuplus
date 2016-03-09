module ApplicationHelper
	def loading_img
		html="<p class='text-center'>#{fa_icon("refresh spin 2x")}</p>"
		return html.html_safe
	end
		def numeric?(string)
	  # `!!` converts parsed number to `true`
	  !!Kernel.Float(string) 
	rescue TypeError, ArgumentError
	  false
	end
end