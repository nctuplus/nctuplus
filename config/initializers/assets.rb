# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

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
