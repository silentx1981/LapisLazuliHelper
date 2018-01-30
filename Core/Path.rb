module LLH
	module Core
		class Path

			def initialize()
			end

			def get(path)
				return path.gsub(/[\.]/, "\\")
			end

		end
	end
end
