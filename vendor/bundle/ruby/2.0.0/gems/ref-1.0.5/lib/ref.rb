module Ref
  require File.join(File.dirname(__FILE__), "ref", "abstract_reference_value_map.rb")
  require File.join(File.dirname(__FILE__), "ref", "abstract_reference_key_map.rb")
  require File.join(File.dirname(__FILE__), "ref", "reference.rb")
  require File.join(File.dirname(__FILE__), "ref", "reference_queue.rb")
  require File.join(File.dirname(__FILE__), "ref", "safe_monitor.rb")

  # Set the best implementation for weak references based on the runtime.
  if defined?(RUBY_PLATFORM) && RUBY_PLATFORM == 'java'
    # Use native Java references
    begin
      $LOAD_PATH.unshift(File.dirname(__FILE__))
      require 'org/jruby/ext/ref/references'
    ensure
      $LOAD_PATH.shift if $LOAD_PATH.first == File.dirname(__FILE__)
    end
  else
    require File.join(File.dirname(__FILE__), "ref", "soft_reference.rb")
    if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ironruby'
      # IronRuby has it's own implementation of weak references.
      require File.join(File.dirname(__FILE__), "ref", "weak_reference", "iron_ruby.rb")
    elsif defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
      # If using Rubinius set the implementation to use WeakRef since it is very efficient and using finalizers is not.
      require File.join(File.dirname(__FILE__), "ref", "weak_reference", "weak_ref.rb")
    elsif defined?(::ObjectSpace::WeakMap)
      # Ruby 2.0 has a working implementation of weakref.rb backed by the new ObjectSpace::WeakMap
      require File.join(File.dirname(__FILE__), "ref", "weak_reference", "weak_ref.rb")
    elsif defined?(::ObjectSpace._id2ref)
      # If ObjectSpace can lookup objects from their object_id, then use the pure ruby implementation.
      require File.join(File.dirname(__FILE__), "ref", "weak_reference", "pure_ruby.rb")
    else
      # Otherwise, wrap the standard library WeakRef class
      require File.join(File.dirname(__FILE__), "ref", "weak_reference", "weak_ref.rb")
    end
  end
  
  require File.join(File.dirname(__FILE__), "ref", "soft_key_map.rb")
  require File.join(File.dirname(__FILE__), "ref", "soft_value_map.rb")
  require File.join(File.dirname(__FILE__), "ref", "strong_reference.rb")
  require File.join(File.dirname(__FILE__), "ref", "weak_key_map.rb")
  require File.join(File.dirname(__FILE__), "ref", "weak_value_map.rb")
  
  # Used for testing
  autoload :Mock, File.join(File.dirname(__FILE__), "ref", "mock.rb")
end
