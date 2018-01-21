module LLH
	module Core

		class Json

			def initialize

			end

			def isJson(text)
				begin
					obj = JSON.parse(text)
				rescue
					return false
				end

				if obj.kind_of?(Integer) == true || obj.kind_of?(Float) == true
					return false
				else
					return true
				end

			end


		end
	end
end


