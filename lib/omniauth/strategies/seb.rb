require 'omniauth'
require_relative 'seb/message'
require_relative 'seb/request'
require_relative 'seb/response'

module OmniAuth
  module Strategies
    class SEB
      class ValidationError < StandardError; end

      AUTH_SERVICE = '0005'

      include OmniAuth::Strategy

      args [:public_crt, :snd_id]

      option :public_crt, nil
      option :snd_id, nil

      option :name, 'seb'
      option :site, 'https://ibanka.seb.lv/ipc/epakindex.jsp'

      uid do
        request.params['IB_USER']
      end

      info do
        {
          full_name: request.params['IB_USER_INFO'].split(" ").reverse.join(" ")
        }
      end

      extra do
        { raw_info: request.params }
      end

      def callback_phase
        if request.params["B02K_CUSTID"] && !request.params["B02K_CUSTID"].empty?
          message = OmniAuth::Strategies::Nordea::Response.new(request.params)
          message.validate!(options.mac)
          super
        else
          fail!(:invalid_credentials)
        end
      rescue ValidationError => e
        fail!(:invalid_mac, e)
      end

      def request_phase
        message = OmniAuth::Strategies::SEB::Request.new(
          'IB_SND_ID': 'AAA',
          'IB_SERVICE': AUTH_SERVICE,
          'IB_LANG': 'LAT'
        )

        # Build redirect form
        form = OmniAuth::Form.new(title: I18n.t('omniauth.seb.please_wait'), url: options.site)

        message.each_pair do |k,v|
          form.html "<input type=\"hidden\" name=\"#{k}\" value=\"#{v}\" />"
        end

        puts form.inspect

        form.button I18n.t('omniauth.seb.click_here_if_not_redirected')
        form.instance_variable_set('@html',
          form.to_html.gsub('</form>', '</form><script type="text/javascript">document.forms[0].submit();</script>'))
        form.to_response
      end

      private

      def callback_with_status_url(status)
        url = URI(callback_url)
        url.query = "omniauth_status=#{status}"
        url
      end
    end
  end
end
