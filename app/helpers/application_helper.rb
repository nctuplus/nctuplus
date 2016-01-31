module ApplicationHelper
	def loading_img
		html="<p class='text-center'>#{fa_icon("refresh spin 2x")}</p>"
		return html.html_safe
	end
end