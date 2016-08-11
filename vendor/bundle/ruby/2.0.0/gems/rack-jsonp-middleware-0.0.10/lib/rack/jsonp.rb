
require 'pathname'

module Rack

  class JSONP

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      requesting_jsonp = Pathname(request.env['PATH_INFO']).extname =~ /^\.jsonp$/i
      callback = request.params['callback']

      return [400,{},[]] if requesting_jsonp && !self.valid_callback?(callback)

      if requesting_jsonp
        env['PATH_INFO'] = env['PATH_INFO'].sub(/\.jsonp/i, '.json')
        env['REQUEST_URI'] = env['PATH_INFO']
      end

      status, headers, body = @app.call(env)

      if requesting_jsonp && self.json_response?(headers['Content-Type'])
        json = ""
        body.each { |s| json << s }
        body = ["/**/#{callback}(#{json});"]
        headers['Content-Length'] = Rack::Utils.bytesize(body[0]).to_s
        headers['Content-Type'] = headers['Content-Type'].sub(/^[^;]+(;?)/, "#{MIME_TYPE}\\1")
      end

      [status, headers, body]
    end

  protected
    
    # Do not allow arbitrary Javascript in the callback.
    #
    # @return [Regexp]
    VALID_CALLBACK_PATTERN = /^[a-zA-Z0-9\._]+$/

    # @return [String] the JSONP response mime type.
    MIME_TYPE = 'application/javascript'

    # Checks if the callback function name is safe/valid.
    #
    # @param [String] callback the string to be used as the JSONP callback function name.
    # @return [TrueClass|FalseClass]
    def valid_callback?(callback)
      !callback.nil? && !callback.match(VALID_CALLBACK_PATTERN).nil?
    end

    # Check if the response Content Type is JSON.
    #
    # @param [Hash] content_type the response Content Type
    # @return [TrueClass|FalseClass]
    def json_response?(content_type)
      !content_type.nil? && !content_type.match(/^application\/json/i).nil?
    end

  end

end
