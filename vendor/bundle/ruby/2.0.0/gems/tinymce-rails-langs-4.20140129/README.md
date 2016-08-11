Language Packs for tinymce-rails
================================

The `tinymce-rails-langs` gem adds language packs for [TinyMCE](http://www.tinymce.com/) (with [tinymce-rails](https://github.com/spohlenz/tinymce-rails)).

The gem currently includes all language packs available from http://www.tinymce.com/i18n/index.php?ctrl=lang&act=download&pr_id=1, some of which may be incomplete.


Instructions
------------

**Add the `tinymce-rails-langs` gem to your Gemfile**

    gem 'tinymce-rails'
    gem 'tinymce-rails-langs'

Language files will then be available during development mode and will be copied across when the `assets:precompile` rake task is run.

See the [tinymce-rails project](https://github.com/spohlenz/tinymce-rails) for further integration instructions.
