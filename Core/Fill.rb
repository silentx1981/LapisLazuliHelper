module LLH
	module Core
		class Fill

			@browser = nil
			@wait = nil
			@key = nil

			def initialize(browser)
				@browser = browser
				@wait = LLH::Core::Wait.new(@browser)
				@key = LLH::Core::Key.new(@browser)
			end

			def fill(element, attribute, id, value)
				result = false
				fillElement = @wait.wait(element, attribute, id)
				if fillElement != nil
					fillElement.set(value.to_s)
					result = true
				else
					result = false
				end
			end

			def fillFile(element, attribut, id, value)
				file = value
				filesRoot = @vars.get(filesRoot)
				file = filesRoot+"\\\\\\\\"+file
				guiName = "GuiTestFile_"+id
				objUpload = @browser.find(:like => [element, attribut, id], :throw => false)
				@browser.execute_script("angular.element(\"input[name='"+guiName+"']\").removeClass('ng-hide')")
				sleep 1
				inputFile = @browser.find(:like => ["input", "name", guiName], :throw => false)
				file = file.gsub('\\', '\\\\\\\\')
				inputFile.send_keys(file)
				@browser.execute_script("angular.element(\"iv-upload[name='"+id+"'] button\").scope().uploadFileGuiTest('"+guiName+"')")
				sleep 1
				@browser.execute_script("angular.element(\"input[name='"+guiName+"']\").addClass('ng-hide')")
			end



			def fillJson(element, attribute, id, value)
				result = false
				json = JSON.parse(value)
				mail = Mail.new(@browser)
				result = mail.execute(json)
				fill(element, attribute, id, result)
			end

			def fillSelect(element, attribute, id, value)
				select = @wait.wait(element, attribute, id)
				if select != nil
					select.click
					fill('input', 'class', 'ui-select-search', value)
					@key.command("enter")
					result = true
				else
					result = false
				end
			end


		end
	end
end

