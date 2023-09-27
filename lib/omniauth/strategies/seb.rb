require 'omniauth'
require 'base64'
require_relative 'seb/message'
require_relative 'seb/response'

module OmniAuth
  module Strategies
    class Seb
      class ValidationError < StandardError; end

      AUTH_SERVICE = '0005'

      include OmniAuth::Strategy

      def self.render_nonce?
         defined?(ActionDispatch::ContentSecurityPolicy::Request) != nil
      end
      if render_nonce?
        include ActionDispatch::ContentSecurityPolicy::Request
        delegate :get_header, :set_header, to: :request
      end

      args [:public_crt, :snd_id]

      option :public_crt, nil
      option :snd_id, nil

      option :name, 'seb'
      option :site, 'https://ibanka.seb.lv/ipc/epakindex.jsp'

      uid do
        request.params['IB_USER']
      end

      info do
        user_info = request.params['IB_USER_INFO']
        full_name = user_info.match(/USER=(.+)/) ? user_info.match(/USER=(.+)/)[1] : user_info.match(/NAME=(.+)/)[1]
        {
          full_name: full_name
        }
      end

      extra do
        { raw_info: request.params }
      end

      def callback_phase
        begin
          pub_crt = OpenSSL::X509::Certificate.new(options.public_crt).public_key
        rescue => e
          return fail!(:public_crt_load_err, e)
        end

        if request.params['IB_SND_ID'] != 'SEBUB'
          return fail!(:invalid_response_snd_id_err)
        end

        if request.params['IB_SERVICE'] != '0001'
          return fail!(:invalid_response_service_err)
        end

        message = OmniAuth::Strategies::Seb::Response.new(request.params)
        message.validate!(pub_crt)

        super
      rescue ValidationError => e
        fail!(:invalid_response_crc, e)
      end

      def request_phase
        fail!(:invalid_snd_id) if options.snd_id.nil?

        set_locale_from_query_param

        message = OmniAuth::Strategies::Seb::Message.new(
          'IB_SND_ID': options.snd_id,
          'IB_SERVICE': AUTH_SERVICE,
          'IB_LANG': resolve_bank_ui_language
        )

        # Build redirect form
        form = OmniAuth::Form.new(title: I18n.t('omniauth.seb.please_wait'), url: options.site)

        message.each_pair do |k,v|
          form.html "<input type=\"hidden\" name=\"#{escape(k.to_s)}\" value=\"#{escape(v)}\" />"
        end

        form.button I18n.t('omniauth.seb.click_here_if_not_redirected')
        nonce_attribute = nil
        if self.class.render_nonce?
          nonce_attribute = " nonce='#{escape(content_security_policy_nonce)}'"
        end
        form.instance_variable_set('@html',
          form.to_html.gsub('</form>', "</form><script type=\"text/javascript\"#{nonce_attribute}>document.forms[0].submit();</script>"))
        form.to_response
      end

      private

      def set_locale_from_query_param
        locale = request.params['locale']
        I18n.locale = locale if I18n.locale_available?(locale)
      end

      def resolve_bank_ui_language
        case I18n.locale
        when :ru then 'RUS'
        when :en then 'ENG'
        else 'LAT'
        end
      end

      def escape(html_attribute_value)
         CGI.escapeHTML(html_attribute_value) unless html_attribute_value.nil?
      end
    end
  end
end
