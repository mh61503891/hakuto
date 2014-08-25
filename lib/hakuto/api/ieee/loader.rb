module Hakuto
  module API
    module IEEE
      class Loader
        class << self
          def load(id)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
