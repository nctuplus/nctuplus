# jquery-ui-sass-rails

This gem packages the jQuery UI 1.10.3 stylesheets in **Sass format (SCSS syntax)** for the Rails 3.1+ [asset
pipeline](http://guides.rubyonrails.org/asset_pipeline.html).

It complements the [jquery-ui-rails](https://github.com/joliss/jquery-ui-rails) gem, which already packages all the plain jQuery UI assets (javascript, css, images), by additionally providing the jQuery UI stylesheets in Sass format allowing much easier customization through Sass variables.  It overwrites the plain CSS stylesheets from `jquery-ui-rails` and leaves everything else untouched.


## Installation

This gem has `jquery-ui-rails` as a dependency, so it's sufficient to include only it in your Gemfile:

```ruby
gem 'jquery-ui-sass-rails'
```

## Sass Stylesheets

Unlike recommended in `jquery-ui-rails` for stylesheets you should always use Sass's `@import` over of Sprocket's `= require`, just as the official `sass-rails` gem [recommends it](https://github.com/rails/sass-rails#important-note).

So the way you import the stylesheets would be something like this:

```sass
// app/assets/stylesheets/application.css.sass

@import jquery.ui.core // you always want that stylesheet
@import jquery.ui.theme // import this when you want to build on jQuery UI's themeing
@import jquery.ui.datepicker // import all the modules you need
```

If you want to include the full jQuery UI CSS, you can do:

```sass
// app/assets/stylesheets/application.css.sass

@import jquery.ui.all
```

The big advantage that the jQuery UI stylesheets have been converted to Sass in this gem is that you now have a super easy way to customize the jQuery UI themes using simple Sass variables.  You simply need to specify your own values **before** you import the `jquery.ui.theme` stylesheet:

```sass
// app/assets/stylesheets/application.css.sass

$bgColorContent: purple // set custom value for jQueryUI variable

@import jquery.ui.core
@import jquery.ui.theme // your custom variables will be used here
@import jquery.ui.datepicker
```

For a list of all jQuery UI variables check out:  https://github.com/jhilden/jquery-ui-sass-rails/blob/master/app/assets/stylesheets/themes/_jquery.ui.base.css.scss


## Themes

`jquery-ui-sass-rails` comes with variable sets for all the themes in the [jQuery UI Themeroller](http://jqueryui.com/themeroller/), you use them by importing the respective partial before the `jquery.ui.theme`:

```sass
// app/assets/stylesheets/application.css.sass

@import themes/jquery.ui.smoothness // variables for 'smothness' theme

@import jquery.ui.core
@import jquery.ui.theme
@import jquery.ui.datepicker
```


## JavaScript

For the JavaScript part you should refer to the [jquery-ui-rails documentation](https://github.com/joliss/jquery-ui-rails) and do something like this:

```javascript
//= require jquery.ui.all
```

or this:

```javascript
//= require jquery.ui.datepicker
```

## Versioning

As long as I don't break any important APIs I will try I try to stick to the versioning of `jquery-ui-rails` with an additional digit.  E.g. `jquery-ui-sass-rails` version `4.0.2.x` goes along with `jquery-ui-rails` version `4.0.2`.


## Credits

This gem is only a complement to the `jquery-ui-rails` gem and wouldn't be possible without it's author [Jo Liss](https://github.com/joliss) and the other [contributors](https://github.com/joliss/jquery-ui-rails/contributors).

Since this is only a gem repackaging the jQuery UI library, the biggest thanks obviously goes out to the [jQueryUI team](http://jqueryui.com/about/).
