module Capybara
  module Selenium
    module Remote
      class << self
        attr_accessor :selenium_host, :server_port, :hostname, :opts
        def use(selenium_host, opts={})
          @selenium_host = selenium_host
          @selenium_url  = "http://#{selenium_host}:4444/wd/hub"
          @server_port   = opts.delete(:server_port) || 9000
          @localhost    = opts.delete(:localhost)    || get_localhost
          @opts          = opts
          Capybara.server_port = @server_port
          Capybara.app_host    = "http://#{@localhost}:#{@server_port}"

          Capybara.register_driver :selenium do |app|
            driver = if defined?(Capybara::Selenium::Driver)
                       Capybara::Selenium::Driver
                     else
                       Capybara::Driver::Selenium
                     end
            driver.new(app, {:url => @selenium_url, :browser => :remote}.merge(opts))
          end
        end

        private

        # http://stackoverflow.com/questions/42566/getting-the-hostname-or-ip-in-ruby-on-rails
        def get_localhost
          orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

          UDPSocket.open do |s|
            s.connect @selenium_host, 1
            s.addr.last
          end
        ensure
          Socket.do_not_reverse_lookup = orig
        end
      end
    end
  end
end

