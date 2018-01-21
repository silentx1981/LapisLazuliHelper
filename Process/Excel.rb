module LLH
	module Process

		class Excel

			@config = nil
			@vars = nil
			@click = nil
			@browser = nil
			@key = nil
			@wait = nil

			def initialize(browser)
				@config = LLH::Core::Config.new
				@vars = LLH::Core::Vars.new
				@browser = LLH::Core::Browser.new(browser)
				@click = LLH::Core::Click.new(browser)
				@fill = LLH::Core::Fill.new(browser)
				@key = LLH::Core::Key.new(browser)
				@verify = LLH::Core::Verify.new(browser)
				@wait = LLH::Core::Wait.new(browser)
			end

			def run(excelfile, parentRequired = 'yes')

				configRoot = @config.get('configRoot')
				workbook = RubyXL::Parser.parse(configRoot+"/"+excelfile)
				worksheet = workbook[0]

				index = 0;
				worksheet.each do |row|
					index = index + 1

					# Get all columns
					next if row == nil
					action = row.cells[0] != nil ? row.cells[0].value : ""
					next if action == 'Action' || action == ''
					element = row.cells[1] != nil ? row.cells[1].value : ""
					attribute = row.cells[2] != nil ? row.cells[2].value : ""
					identifier = row.cells[3] != nil ? row.cells[3].value : ""
					content = row.cells[4] != nil ? row.cells[4].value : ""
					required = row.cells[5] != nil ? row.cells[5].value : ""
					deactivate = row.cells[6] != nil ? row.cells[6].value : ""

					# When deactivate ignore this line
					next if deactivate == 'yes'

					# Get the Parsed Value
					content = @vars.getParsedValue(content)

					# Execute the action
					result = false
					case action
						when "click"
							result = @click.clickElement(element, attribute, identifier, content)
						when "clickTableElement"
							result = @click.clickTableElement(element, attribute, identifier, content)
						when "command"
							result = @key.command(identifier)
						when "copyVars"
							result = @vars.copyVars(identifier, content)
						when "fill"
							result = @fill.fill(element, attribute, identifier, content)
						when "fillFile"
							result = @fill.fillFile(element, attribute, identifier, content)
						when "fillJson"
							result = @fill.fillJson(element, attribute, identifier, content)
						when "fillSelect"
							result = @fill.fillSelect(element, attribute, identifier, content)
						when "open"
							result = @browser.open(content)
						when "openJson"
							result = @browser.openJson(content)
						when "include"
							result = run(content, required)
						when "keys"
							result = @key.sendKeys(identifier)
						when "setVars"
							result = @vars.setVarsByExcel(content)
						when "verify"
							result = @verify.verify(element, attribute, identifier, content)
						when "wait"
							result = @wait.waitTime(identifier)
					end

					if result == false && required == 'yes' && parentRequired == 'yes'
						print "Error in LLH::Process::Excel \n"
						print "Row "+index.to_s+" \n"
						print "File: "+excelfile+"\n"
						print "Line-Informations: "+action.to_s+"/"+identifier.to_s+"/"+content.to_s+" \n"
						print "\n\n"
						break
					end

				end

			end

		end
	end

end

