module LLH
	module Core

		class Vars

			@config = nil

			def initialize

				@config = LLH::Core::Config.new
				if ($vars == nil)
					$vars = {}
				end
				@path = LLH::Core::Path.new
			end

			def copyVars(from, to, fromParse = false)
				allVars = $vars.dup
				allVars.each do |key, var|
					newkey = key.dup
					if (fromParse == true)
						matches = from.scan(/(\{[A-Za-z0-9]*?\}){1}/)
						matches.each do |match|
                        	if match != nil
                        		onlytext = match[0].gsub(/([\{\}])/, '')
                        		if $vars.key?(onlytext)
                        			from = from.sub(match[0], $vars[onlytext].to_s)
                        		end
                        	end
                        end
					end
					newkey = newkey.sub! from, to
					if newkey != nil
						$vars[newkey] = var
					end
				end
				return true
			end

			def getParsedValue(value)
				if value.kind_of?(String) && value.include?("{") && value.include?("}")
					matches = value.scan(/(\{[A-Za-z0-9-]*?\})/)
					matches.each do |match|
						if match != nil
							onlytext = match[0].gsub(/([\{\}])/, '')
							if $vars.key?(onlytext)
								value = value.sub(match[0], $vars[onlytext].to_s)
							end
						end
					end
				end

				if $vars.key?(value)
					value = $vars[value]
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
					workbook = RubyXL::Parser.parse(@path.get(configRoot.to_s+"."+excelfile.to_s)+".xlsx")
				else
					workbook = RubyXL::Parser.parse(@path.get(excelfile.to_s)+".xlsx")
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
						when 'setVarsPersonsByExcel'
							setVarsPersonsByExcel(name, value)
					end
				end
				result = true
			end

			def setVarsPersonsByExcel(element, excelfile)
				configRoot = @config.get("configRoot")
				if configRoot.to_s != ''
					workbook = RubyXL::Parser.parse(@path.get(configRoot.to_s+"."+excelfile.to_s)+".xlsx")
				else
					workbook = RubyXL::Parser.parse(@path.get(excelfile.to_s)+".xlsx")
				end
				worksheet = workbook[0]

				index = 0
				titleFields = []
				worksheet.each do |row|
					next if row == nil
					if index == 0
						row.cells.each do |col|
							colvalue = col.value != nil ? col.value : ""
							titleFields.push(colvalue)
						end
					end
					index = index + 1
					next if index == 0

					row.cells.each_with_index do |col, key|
						colvalue = col.value != nil ? col.value : ""
						set(element+row.cells[0].value.to_s+"-"+titleFields[key].to_s, colvalue.to_s)
					end

					#identifier = row.cells[0] != nil ? row.cells[0].value : ""
					#next if identifier == '' || identifier == 'Identifier'
					#mail = row.cells[1] != nil ? row.cells[1].value : ""
					#name = row.cells[2] != nil ? row.cells[2].value : ""
					#vorname = row.cells[3] != nil ? row.cells[3].value : ""
					#login = row.cells[4] != nil ? row.cells[4].value : ""
					#passwort = row.cells[5] != nil ? row.cells[5].value : ""
					#affiliationlink = row.cells[6] != nil ? row.cells[6].value : ""
					#roletext = row.cells[7] != nil ? row.cells[7].value : ""
					#strasse = row.cells[8] != nil ? row.cells[8].value : ""
					#plz = row.cells[9] != nil ? row.cells[9].value : ""
					#ort = row.cells[10] != nil ? row.cells[10].value : ""
					#telefon = row.cells[11] != nil ? row.cells[11].value : ""
					#firma = row.cells[12] != nil ? row.cells[12].value : ""
					#firmastrasse = row.cells[13] != nil ? row.cells[13].value : ""
					#firmaplz = row.cells[14] != nil ? row.cells[14].value : ""
					#firmaort = row.cells[15] != nil ? row.cells[15].value : ""
					#firmatelefon = row.cells[16] != nil ? row.cells[16].value : ""
#
					#fullname = vorname+" "+name
					#fullnameback = name+" "+vorname
					#password = passwort
#
					#set(element+identifier.to_s+"-mail", mail)
					#set(element+identifier.to_s+"-name", name)
					#set(element+identifier.to_s+"-vorname", vorname)
					#set(element+identifier.to_s+"-login", login)
					#set(element+identifier.to_s+"-passwort", passwort)
					#set(element+identifier.to_s+"-affiliationlink", affiliationlink)
					#set(element+identifier.to_s+"-roletext", roletext)
					#set(element+identifier.to_s+"-strasse", strasse)
					#set(element+identifier.to_s+"-plz", plz.to_s)
					#set(element+identifier.to_s+"-ort", ort.to_s)
					#set(element+identifier.to_s+"-telefon", telefon.to_s)
					#set(element+identifier.to_s+"-firma", firma)
					#set(element+identifier.to_s+"-firma-strasse", firmastrasse)
					#set(element+identifier.to_s+"-firma-plz", firmaplz.to_s)
					#set(element+identifier.to_s+"-firma-ort", firmaort)
					#set(element+identifier.to_s+"-firma-telefon", firmatelefon)
					#set(element+identifier.to_s+"-fullname", fullname)
					#set(element+identifier.to_s+"-fullnameback", fullnameback)
					#set(element+identifier.to_s+"-password", password)

				end
			end


		end


	end
end

