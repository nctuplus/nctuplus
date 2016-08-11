require 'json'
require 'bundler/gem_tasks'
require 'pry-debugger'

desc 'remove SCSS files'
task :clean_scss do
  rm_rf 'app/assets/*'
  puts "cleaned old SCSS files"
  puts "-----"
end

desc 'move jquery-ui-rails stylesheets'
task :move_stylesheets do
  target_dir = 'jquery-ui-rails/stylesheets'
  mkdir_p target_dir
  system("mv app/assets/stylesheets/*.erb #{target_dir}")
  puts "move stylesheets to #{target_dir} (if necesarry)"
  puts "-----"
end

desc "Convert stylesheets to SCSS"
task :convert_to_scss do
  source_dir = 'jquery-ui-rails/stylesheets'
  target_dir = 'app/assets/stylesheets'
  mkdir_p target_dir
  variables_hash = {}

  # convert css files to scss
  Dir.glob("#{source_dir}/*.erb").each do |source_file|
    puts source_file
    stylesheet_content = File.read(source_file)

    # replace image_path ERB with image-url Sass
    stylesheet_content.gsub!(/<%= image_path\((\S+)\) %>/) { "image-path(#{$1})" }

    # remove comment blocks with sprockets require directives, because they don't work well with Sass variables
    stylesheet_content.gsub!(/\/\*[^\/]+require[^\/]+\*\//) do |match|
      if source_file.end_with?('jquery.ui.theme.css.erb')
        "@import 'themes/jquery.ui.base';\n"

      elsif source_file.end_with?('jquery.ui.all.css.erb') || source_file.end_with?('jquery.ui.base.css.erb')
        match.gsub!(/ \*= require ([a-z\.]+)/) { "@import '#{$1}';" }
        match.gsub!(/\/\*| \*\//, '')

      else
        ''
      end
    end

    # extract vars
    regex = /(url\(<%= image_path\([\S]+\) %>\)|[\S]+)\/\*{([a-z]+)}\*\//i
    vars = stylesheet_content.scan regex

    # write variables to gobal hash
    vars.each do |var|
      value = var[0]
      name = var[1]
      variables_hash[name] ||= value
    end

    # write SCSS file
    destination_file_name = File.basename(source_file).gsub(".css.erb", ".css.scss")
    destination_file = File.open "#{target_dir}/#{destination_file_name}", 'w'
    destination_file << stylesheet_content.gsub(regex) { "$#{$2}" }
    destination_file.close
    puts "> .css.scss"
    puts "--"
  end

  # write _jquery.ui.base.css.scss
  mkdir_p "#{target_dir}/themes"
  variables_stylesheet = File.open "#{target_dir}/themes/_jquery.ui.base.css.scss", 'w'
  variables_hash.each do |name, value|
    variables_stylesheet << "$#{name}: #{value} !default;\n"
  end
  variables_stylesheet.close
  puts "wrote _jquery.ui.base.css.scss"
  puts "-----"
end

task :themes do
  def get_value(lines, line_number)
    lines[line_number-1].split(':').last.gsub(';', '').strip
  end

  Dir['jquery-ui-themes/themes/*'].each do |theme_dir|
    theme_name = theme_dir.split('/').last
    puts theme_name

    # copy image assets
    image_target_dir = "app/assets/images/jquery-ui"
    mkdir_p image_target_dir
    FileUtils.cp(Dir.glob("#{theme_dir}/images/*"), image_target_dir)

    theme_css = File.open("#{theme_dir}/jquery.ui.theme.css").read
    theme_css.gsub!(/\r\n?/, "\n")
    lines = theme_css.each_line.map{ |line| line }

    vars = {
      ffDefault: get_value(lines, 18),
      fsDefault: get_value(lines, 19),
      borderColorContent: get_value(lines, 32).split(' ').last,
      fcContent: get_value(lines, 34),
      borderColorHeader: get_value(lines, 40).split(' ').last,
      fcHeader: get_value(lines, 42),
      borderColorDefault: get_value(lines, 54).split(' ').last,
      fwDefault: get_value(lines, 56),
      fcDefault: get_value(lines, 57),
      borderColorHover: get_value(lines, 71).split(' ').last,
      fwHover: get_value(lines, 73),
      fcHover: get_value(lines, 74),
      borderColorActive: get_value(lines, 86).split(' ').last,
      fwActive: get_value(lines, 88),
      fcActive: get_value(lines, 89),
      borderColorHighlight: get_value(lines, 103).split(' ').last,
      fcHighlight: get_value(lines, 105),
      borderColorError: get_value(lines, 115).split(' ').last,
      fcError: get_value(lines, 117),
      iconsContent: get_value(lines, 162),
      iconsHeader: get_value(lines, 165),
      iconsDefault: get_value(lines, 168),
      iconsHover: get_value(lines, 172),
      iconsActive: get_value(lines, 175),
      iconsHighlight: get_value(lines, 178),
      iconsError: get_value(lines, 182),
      cornerRadius: get_value(lines, 372),
      opacityOverlay: get_value(lines, 396),
      opacityFilterOverlay: get_value(lines, 397),
      offsetTopShadow: get_value(lines, 400).split(' ').first,
      offsetLeftShadow: get_value(lines, 400).split(' ').last,
      thicknessShadow: get_value(lines, 401),
      opacityShadow: get_value(lines, 403),
      opacityFilterShadow: get_value(lines, 404),
      cornerRadiusShadow: get_value(lines, 405),
    }

    backgrounds = {
      "Content" => 33,
      "Header" => 41,
      "Default" => 55,
      "Hover" => 72,
      "Active" => 87,
      "Highlight" => 104,
      "Error" => 116,
      "Overlay" => 395,
      "Shadow" => 402
    }
    backgrounds.each do |background, line_number|
      values = get_value(lines, line_number).split(' ')
      var_names = ["bgColor#{background}", "bgImgUrl#{background}", "bg#{background}XPos", "bg#{background}YPos", "bg#{background}Repeat"]
      vars.merge! Hash[var_names.zip values]
    end

    # image paths
    vars.each do |key, value|
      if value.to_s.start_with? 'url(images/'
        value.gsub! 'url(images/', 'url(image-path("jquery-ui/'
        value.gsub! ')', '"))'
        vars[key] = value
      end
    end

    target_dir = 'app/assets/stylesheets/themes'
    mkdir_p target_dir
    theme_stylesheet = File.open "#{target_dir}/_jquery.ui.#{theme_name}.css.scss", 'w'
    vars.each do |name, value|
      theme_stylesheet << "$#{name}: #{value} !default;\n"
    end
    theme_stylesheet.close
  end
end

task :scss_process => [:clean_scss, :move_stylesheets, :convert_to_scss, :themes]

task :default => :scss_process
