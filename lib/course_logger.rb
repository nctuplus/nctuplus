class CourseLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end
end
 
logfile = File.open("#{Rails.root}/log/import_course.log", 'a')  # create log file
logfile.sync = true  # automatically flushes data to file
COURSE_LOGGER = CourseLogger.new(logfile)  # constant accessible anywhere