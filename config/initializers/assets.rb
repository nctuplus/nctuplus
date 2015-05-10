# Remember to update this file when you add or delete custom js files in app/assets/javascripts
# Modified at 2015/4/15

Rails.application.config.assets.precompile +=[
	'tmpl.min.js',
	'bootstrap-treeview.js',
	'courses/content.js',
	'courses/chart.js',	
	'courses/table.js',
	'courses/past_exam.js',
	'course_maps/manage.js',
	'course_maps/public.js',
	'user_course_stat/checker.js',
	'user_course_stat/cm_check-helper.js'
]
