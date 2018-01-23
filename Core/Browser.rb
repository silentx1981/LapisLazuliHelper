module LLH
	module Core
		class Browser

			@browser = nil
			@json = nil
			@vars = nil

			def initialize(browser)
				@browser = browser
				@json = LLH::Core::Json.new
				@vars = LLH::Core::Vars.new
			end

			def copyToClipboard(text)
				str = text.to_s
				IO.popen('pbcopy', 'w') { |f| f << str }
				str
			end

			def getBrowser
				return @browser
			end

			def open(url)
				result = false
				if (@json.isJson(url))
					## getUrl from other URL JSON-Object
				end
				if url.to_s.match(/(^http:\/\/)/) == nil && url.to_s.match(/(^https:\/\/)/) == nil
					url = @vars.getParsedValue(url)
				end
				begin
					@browser.goto url.to_s
					result = true
				rescue
					result = false
				end
			end

			def openJson(value)
				result = false
				json = JSON.parse(value)
				mail = LLH::Core::Mail.new(@browser)
				result = mail.execute(json)
				open(result)
			end

		end
	end
end
