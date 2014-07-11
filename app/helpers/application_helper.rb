module ApplicationHelper
  def course_tag
    html=""
    Course.all.each do |course|
	html<<'"'<<course.eng_name<<'",'
	end
	html=""
	return html
  end
  def div_alert
	'<div class="alert alert-danger">'
  end
  def div_notice
    '<div class="alert alert-notice">'
  end
  def clippy(text, bgcolor='#000000')
  html = <<-EOF
    <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
            width="110"
            height="20"
            id="clippy" >
    <param name="movie" value="/clippy.swf"/>
    <param name="allowScriptAccess" value="always" />
    <param name="quality" value="high" />
    <param name="scale" value="noscale" />
    <param NAME="FlashVars" value="text=#{text}">
    <param name="bgcolor" value="#{bgcolor}">
    <embed src="/clippy.swf"
           width="110"
           height="20"
           name="clippy"
           quality="high"
           allowScriptAccess="always"
           type="application/x-shockwave-flash"
           pluginspage="http://www.macromedia.com/go/getflashplayer"
           FlashVars="text=#{text}"
           bgcolor="#{bgcolor}"
    />
    </object>
  EOF
  end
end
