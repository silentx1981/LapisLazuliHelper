module LLH
	module Core

		class Vars

			@config = nil

			def initialize

				@config = LLH::Core::Config.new
				if ($vars == nil)
					$vars = {}
				end
			end

			def copyVars(from, to)
				allVars = $vars.dup
				allVars.each do |key, var|
					newkey = key.dup
					newkey = newkey.sub! from, to
					if newkey != nil
						$vars[newkey] = var
					end
				end
				return true
			end

			def getParsedValue(value)

				if $vars.key?(value)
					value = $vars[value]
				end

				if value.kind_of?(String) && value.include?("{") && value.include?("}")
					matches = value.scan(/(\{[A-Za-z0-9]*?\}){1}/)
					matches.each do |match|
						if match != nil
							onlytext = match[0].gsub(/([\{\}])/, '')
							if $vars.key?(onlytext)
								value = value.sub(match[0], $vars[onlytext])
							end
						end
					end
				end
				return value
			end

			def get(name)
				return $vars[name]
			end

			def set(name, value)
				$vars[name] = value
			end

			def setVarsByExcel(excelfile)
				configRoot = @config.get("configRoot")
				if configRoot.to_s != ''
					workbook = RubyXL::Parser.parse(configRoot+"/"+excelfile)
				else
					workbook = RubyXL::Parser.parse(excelfile)
				end
				worksheet = workbook[0]

				worksheet.each do |row|
					next if row == nil
					action = row.cells[0] != nil ? row.cells[0].value : ""
					next if action == 'Action' || action == ''
					name = row.cells[1] != nil ? row.cells[1].value : ""
					value = row.cells[2] != nil ? row.cells[2].value : ""

					case action
						when 'copy'
							copyVars(name, value)
						when 'include'
							setVarsByExcel(value)
						when 'set'
							set(name, value)
					end
				end
				result = true
			end


		end


	end
end

