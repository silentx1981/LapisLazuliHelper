module LLH
	module Core
		class Config

			def initialize
				if ($config == nil)
					$config = {}
				end
			end

			def get(name)
				return $config[name]
			end

			def set(name, value)
				$config[name] = value
				return value;
			end

			def setConfigByExcel(excelfile)

				workbook = RubyXL::Parser.parse(excelfile)
				worksheet = workbook[0]

				worksheet.each do |row|
					next if row == nil
					action = row.cells[0] != nil ? row.cells[0].value : ""
					next if action == 'Action' || action == ''
					name = row.cells[1] != nil ? row.cells[1].value : ""
					value = row.cells[2] != nil ? row.cells[2].value : ""
					case action
						when 'set'
							set(name, value)
						when 'include'
							setIncludeConfigByExcel(value)
					end

				end
			end

			def setIncludeConfigByExcel(excelfile)
				configRoot = get("configRoot")
				if (configRoot.to_s != '')
					setConfigByExcel(configRoot+"/"+excelfile)
				else
					setConfigByExcel(excelfile)
				end
			end

		end
	end
end
