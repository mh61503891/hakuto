module Hakuto
  module API
    module IEEE
      class Reader
        class << self
          def read(id)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
