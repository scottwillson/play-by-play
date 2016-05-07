require "play_by_play/model/possession"

module PlayByPlay
  module Persistent
    class Possession < Model::Possession
      attr_accessor :play

      def to_s
        "#<PlayByPlay::Persistent::Possession #{key}>"
      end
    end
  end
end
