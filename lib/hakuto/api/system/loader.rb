require 'hakuto/api/system/adapter'

module Hakuto
	module API
		module System
			class Loader < Hakuto::API::Loader
				def load(id)
					Paper.get(id)
				end
			end
		end
	end
end
