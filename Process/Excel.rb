module LLH
	module Process

		class Excel

			@config = nil
			@vars = nil
			@click = nil
			@browser = nil
			@key = nil
			@wait = nil
			@path = nil
			@subs = nil
			@print = nil

			def initialize(browser)
				@config = LLH::Core::Config.new
				@vars = LLH::Core::Vars.new
				@browser = LLH::Core::Browser.new(browser)
				@click = LLH::Core::Click.new(browser)
				@fill = LLH::Core::Fill.new(browser)
				@key = LLH::Core::Key.new(browser)
				@verify = LLH::Core::Verify.new(browser)
				@wait = LLH::Core::Wait.new(browser)
				@path = LLH::Core::Path.new
				@showProgress = @config.get('showProgress')
				@print = LLH::Core::Print.new
				@subs = ""
			end

			def run(excelfile, parentRequired = 'yes', sub = 0)

				configRoot = @config.get('configRoot')
				workbook = RubyXL::Parser.parse(@path.get(configRoot + "." + excelfile)+".xlsx")
				worksheet = workbook[0]

				index = 0;
				worksheet.each do |row|
					index = index + 1

					# Get all columns
					next if row == nil
					action = row.cells[0] != nil ? row.cells[0].value : ""
					next if action == 'Action' || action == nil || action.strip == ""
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

					if @showProgress == 'yes'
						i = 0
						@subs = ""
						while i < sub
							@subs =  @subs + " > "
							i = i + 1
						end
						print @subs + excelfile.to_s + " / Row: " + index.to_s
					end

					# Find the Waiting-Time from the Action-Statement
					waitBefore = action.sub(/([A-Za-z]*[0-9]*)$/, "")
					waitAfter = action.sub(/^([0-9]*[A-Za-z]*)/, "")
					action = action.gsub(/([^A-Za-z]*)/, "")

					# Wait Before
					if waitBefore.to_i > 0
						sleep waitBefore.to_i
					end

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
							result = @vars.copyVars(identifier, content, true)
						when "fill"
							result = @fill.fill(element, attribute, identifier, content)
						when "fillDate"
							result = @fill.fillDate(element, attribute, identifier, content)
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
							result = include(element, attribute, identifier, content, required, (sub + 1))
						when "keys"
							result = @key.sendKeys(identifier)
						when "run"
							result = Object.const_get(identifier.to_s).new(@browser).run(content)
						when "screenshot"
							result = @browser.takeScreenshot()
						when "setVars"
							result = @vars.setVarsByExcel(content)
						when "setVarsPerson"
							result = @vars.setVarsPersonsFromExcel(element, content)
						when "verify"
							result = @verify.verify(element, attribute, identifier, content)
						when "wait"
							result = @wait.waitTime(identifier)
					end

					# Wait After
					if waitAfter.to_i > 0
						sleep waitAfter.to_i
					end

					if @showProgress == 'yes' && action != 'include' && action != 'run'
						if result == false
							@browser.takeScreenshot()
							print " / Failed \n"
						else
							print " / OK \n"
						end
					end

					if result == false && required == 'yes' && parentRequired == 'yes'
						print "Error in LLH::Process::Excel \n"
						print "Row " + index.to_s + " \n"
						print "File: " + excelfile + "\n"
						print "Line-Informations: " + action.to_s + "/" + identifier.to_s + "/" + content.to_s + " \n"
						print "\n\n"
						@browser.takeScreenshot()
						return false
					end

				end

			end

			def include(element, attribute, identifier, content, required, sub)
				if @showProgress == 'yes'
					print " / OK \n"
				end
				if element != "" && element != nil && attribute != "" && attribute != nil
					@vars.copyVars(element, attribute, true)
				end
				result = run(content, required, sub)
			end

		end
	end

end

