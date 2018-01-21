module LLH
	module Core

		class Mail

			@browser = nil
			@fill = nil
			@wait = nil
			@click = nil
			@config = nil
			@vars = nil

			def initialize(browser)
				@browser = LLH::Core::Browser.new(browser)
				@fill = LLH::Core::Fill.new(browser)
				@wait = LLH::Core::Wait.new(browser)
				@click = LLH::Core::Click.new(browser)
				@config = LLH::Core::Config.new
				@vars = LLH::Core::Vars.new
			end

			def execute(config)
				result = ""
				if config.key?("action")
					case @config.get('mailSystem')
						when "Pronto"
							result = getOnProntoMail(config)
						when "Inbucket"
							result = getInbucketMail(config)
					end
				end
			end

			def getOnProntoMail(config)

				# Load Config
				action = config['action'] != nil ? config['action'] : ""
				url = @config.get('mailSystemUrl')
				user = @config.get('mailSystemUser')
				password = @config.get('mailSystemPassword')
				reciever = config['reciever'] != nil ? config['reciever'] : ""
				searchRegex = config['searchRegex'] != nil ? config['searchRegex'] : ""
				resultRegex = config['resultRegex'] != nil ? config['resultRegex'] : ""
				result = '';

				@browser.open(url)
				@fill.fill('input', 'name', 'username', user)
				@fill.fill('input', 'name', 'Password', password)
				@click.clickElement('input', 'name', 'login', '')

				sleep 5 # Waiting-Time for loading Mail-Messages
				@wait.wait('div', 'id', 'mail-messages')
				messages = @browser.getBrowser().find_all(:like   => [:div, :class, "pronto-mail-list__item"], :throw => false)
				counter = 0
				messages.each do |div|
					counter = counter + 1
					break if counter > 5
					div.click
					sleep 1
					@wait.wait('frame', 'id', 'mailContent')
					messageFrameText = @browser.getBrowser().find(:like => [:iframe, :id, "mailContent"]).text

					# Check Receiver
					reciever = @vars.getParsedValue(reciever)
					recieverRegex = Regexp.new(reciever)
					recieverfound = messageFrameText.match(recieverRegex)
					if recieverfound == nil
						next
					end

					# Search
					searchRegex = Regexp.new(searchRegex)
					search = messageFrameText.match(searchRegex)
					if search == nil
						next
					end

					# Get Result
					resultRegex = Regexp.new(resultRegex)
					result = search[0].match(resultRegex)
					if result == nil
						next
					end

					break if result != nil

				end
				@browser.open('pageRoot')
				return result
			end

			def getInbucketMail(config)
				# Load Config
				action = config['action'] != nil ? config['action'] : ""
				url = @config.get('mailSystemUrl')
				reciever = config['reciever'] != nil ? config['reciever'] : ""
				searchRegex = config['searchRegex'] != nil ? config['searchRegex'] : ""
				resultRegex = config['resultRegex'] != nil ? config['resultRegex'] : ""
				result = '';

				@browser.open(url.to_s+"/monitor")
				sleep 1 # Wartezeit für das Laden der Mails
				@wait.wait('div', 'id', 'mail-messages')
				messages = @browser.getBrowser().find_all(:like   => [:tr, :onclick, "messageClick(this)"], :throw => false)
				browserMessage = LapisLazuli::Browser.new(:chrome)
				counter = 0
				messages.each do |tr|
					counter = counter + 1
					break if counter > 8
					browserMessage.goto url.to_s+"/"+tr.attribute_value('href')
					waitHtmlMessage = LLH::Core::Wait.new(browserMessage)
					sleep 1

					messageText = waitHtmlMessage.wait('div', 'class', 'message-body').text

					# Check Receiver
					reciever = @vars.getParsedValue(reciever)
					recieverRegex = Regexp.new(reciever)
					recieverfound = messageText.match(recieverRegex)
					if recieverfound == nil
						next
					end

					# Search
					searchRegex = Regexp.new(searchRegex)
					search = messageText.match(searchRegex)
					if search == nil
						next
					end

					# Get Result
					resultRegex = Regexp.new(resultRegex)
					result = search[0].match(resultRegex)
					if result == nil
						next
					end
					break if result != nil
				end

				browserMessage.close
				@browser.open('pageRoot')
				return result
			end





		end
	end
end