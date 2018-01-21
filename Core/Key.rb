module LLH
	module Core
		class Key

			@browser = nil

			def initialize(browser)
				@browser = browser
			end

			def command(command)
				result = false
				if (command == 'enter')
					@browser.send_keys(:enter)
					sleep 1
					result = true
				end
			end

			def sendKeys(keys)
				sleep 2 # Without this sleep this not work
				@browser.send_keys(keys)
				result = true
			end

		end
	end
end

