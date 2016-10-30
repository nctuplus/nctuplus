require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class NCTU < OmniAuth::Strategies::OAuth2
      option :name, "NCTU"

      option :client_options, {
        :site => NCTUOAUTH::SITE,
        :authorize_url => NCTUOAUTH::AUTH_URL,
        :token_url => NCTUOAUTH::GET_TOKEN_URL
      }

      option :token_params, {
        grant_type: "authorization_code"
      }

      option :access_token_options, {
        header_format: 'Bearer %s',
      }

      extra do
        hash = {}
        hash["profile"] = r_profile
        prune! hash
      end

      def r_profile
        @r_profile ||= access_token.get(NCTUOAUTH::SITE+NCTUOAUTH::API_PROFILE_URL).parsed
      end

      def prune!(hash)
        hash.delete_if do |_,v|
          prune!(v) if v.is_a?(Hash)
          v.nil? || (v.respond_to?(:empty?) && v.empty?)
        end
      end

      def callback_phase
        super
      end
    end
  end
end
