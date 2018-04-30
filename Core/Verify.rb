module LLH
	module Core
		class Verify

			@browser = nil
			@wait = nil

			def initialize(browser)
				@browser = browser
				@wait = LLH::Core::Wait.new(browser)
			end

			def verify(element, attribute, identifier, content)
				verifyElement = @wait.wait(element, attribute, identifier)
				if verifyElement == nil && content != '' && content != nil
					verifyElement = @wait.wait(element, attribute, content)
				elsif verifyElement != nil && content != ''
					return verifyElement.text == content.to_s
				end
				if verifyElement != nil
					result = true
				else
					result = false
				end
			end

			def notVerify(element, attribute, identifier, content)
				verifyElement = @wait.wait(element, attribute, identifier)
				if verifyElement == nil && content != '' && content != nil
					verifyElement = @wait.wait(element, attribute, content)
				end
				if verifyElement == nil
					result = true
				else
					result = false
				end
			end
		end
	end
end

