module OmniAuth
  module Strategies
    class Seb
      class Message
        def initialize(hash)
          @hash = hash
        end

        def to_hash
          @hash
        end

        def each_pair(&block)
          @hash.each_pair(&block)
        end
      end
    end
  end
end
