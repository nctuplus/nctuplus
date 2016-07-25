require 'omniauth'

module OmniAuth
  module Strategies
    class E3
      include OmniAuth::Strategy
      
     def initailize(app)
      super(app, :e3)
     end 
      
      
     # def request_phase
        
     # end
      
      def callback_phase
        super
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super(), { 
          # data here
        })
      end
      
    end
  end
end