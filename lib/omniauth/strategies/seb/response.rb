module OmniAuth
  module Strategies
    class Seb
      class Response < Message
        SIGNED_KEYS = [
          'IB_SND_ID',    # SEBUB
          'IB_SERVICE',   # 0001
          'IB_REC_ID',
          'IB_USER',
          'IB_DATE',
          'IB_TIME',
          'IB_USER_INFO',
          'IB_VERSION'
        ]

        def prepend_length(value)
          # prepend length to string in 0xx format
          [ value.to_s.length.to_s.rjust(3, '0'), value.dup.to_s.force_encoding('ascii')].join
        end

        def validate!(pub_key)
          raw_str = SIGNED_KEYS.map{|k| prepend_length(@hash[k])}.join
          received_sig_str = Base64.decode64(@hash['IB_CRC'])

          if !pub_key.verify(OpenSSL::Digest::SHA1.new, received_sig_str, raw_str)
            raise ValidationError, 'Invalid signature'
          end

          self
        end
      end
    end
  end
end
