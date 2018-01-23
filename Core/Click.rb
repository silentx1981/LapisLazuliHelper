module LLH
	module Core
		class Click

			@browser = nil
			@wait = nil
			@vars = nil

			def initialize(browser)
				@browser = browser
				@wait = LLH::Core::Wait.new(@browser)
				@vars = LLH::Core::Vars.new
			end

			def clickElement(element, attribute, id, value)
				@wait.waitDisappear("div", "data-notify", "container")
				clickElement = @wait.wait(element, attribute, id)
				if clickElement == nil
					clickElement = @wait.wait(element, attribute, value)
				end
				if clickElement != nil
					i = 0
					isEnabled = false
					while i < 5
						if clickElement.enabled?
							isEnabled = true
							break
						end
						i = i + 1
						sleep 1
					end
					if isEnabled == true
						clickElement.click
						sleep 1
						result = true
					else
						result = false
					end
				else
					result = false
				end
			end

			def clickTableElement(element, attribute, id, value)
				sleep 2 # Need this waiting time
				json = JSON.parse(value)
				searchObj = {}
				searchArr = {}
				json.each do |key,value|
					if @vars.get(value) != nil
						searchObj[key] = @vars.get(value)
					else
						searchObj[key] = value
					end
					if key.to_i.to_s == key
						searchArr["column_"+key] = searchObj[key]
					end
				end

				table = @wait.wait(element, attribute, id)
				foundRow = nil
				table.trs.each do | tr |
					foundColumn = 0
					columnNr = -1
					tr.tds.each do | td |
						columnNr = columnNr + 1
						if searchArr.key?("column_"+columnNr.to_s) && td.text == searchArr["column_"+columnNr.to_s]
							foundColumn = foundColumn + 1
						end
					end
					if foundColumn == searchArr.length
						foundRow = tr
					end
					break if foundRow != nil
				end

				if foundRow != nil
					a = nil
					if json['data-original-title'] != nil
						a = foundRow.tds.last.a(:"data-original-title" => json['data-original-title'])
					elsif json['uib-tooltip'] != nil
						a = foundRow.tds.last.a("uib-tooltip" => json['uib-tooltip'])
					elsif json['buttontext'] != nil
						a = foundRow.tds.last.button(:text => json['buttontext'])
					end
					if a != nil
						a.click
						result = true
					else
						result = false
					end
				else
					result = false
				end
			end



		end
	end
end

