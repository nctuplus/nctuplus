# Remember to update this file when you add or delete custom js files in app/assets/javascripts
# Modified at 2015/11/17

Rails.application.config.assets.precompile +=[
	'tmpl.min.js',
	#'bootstrap-treeview.js',
	'courses/content.js',
	'courses/chart.js',	
	'courses/html2canvas.js',
	'courses/table.js',
	'courses/past_exam.js',
	'courses/simulation.js',
	'course_maps/manage.js',
	'course_maps/public.js',
	'user_course_stat/checker.js',
	'user_course_stat/cm_check-helper.js',
	'user_course_stat/report-table.js',
	'admin_statistics/index.js',
	'books.js',
	'new-index.js',
	'new-index.css',
	'login.css',
	'events.css',
	'events_show.css',
	'jquery-ui-timepicker-addon.js',
	'event_create.js',
	'jquery.counterup.js',
	'waypoints.min.js'

]
