module LLH
	module Core
		class Wait

			@browser = nil
			@config = nil
			@defaultTimeout = 0;

			def initialize(browser)
				@browser = browser
				@config = LLH::Core::Config.new

				@defaultTimeout = @config.get('defaultTimeout').to_i
			end

			def wait(element, attribute, id)
				if attribute == "class"
					instance = @browser.wait(
						element.to_s => {:class => id.to_s},
						:condition   => :until,
						:throw       => false,
						:timeout     => @defaultTimeout
					)
				else
					instance = @browser.wait(
						element.to_s => {attribute.to_s => id.to_s},
						:condition   => :until,
						:throw       => false,
						:timeout     => @defaultTimeout
					)
				end
			end

			def waitDisappear(element, attribute, id)
				instance = @browser.wait(
            		element.to_s => {attribute.to_s => id.to_s},
            		:condition   => :while,
            		:throw       => false,
            		:timeout     => @defaultTimeout
            )
			end

			def waitTime(time)
				sleep time.to_i
				result = true
			end

		end



	end
end
