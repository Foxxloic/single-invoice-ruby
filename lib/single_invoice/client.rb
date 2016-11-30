require 'httparty'

# TODO: remove once API server is case-insensitive with http header names
module Net::HTTPHeader
  def capitalize(name)
    name
  end
  private :capitalize
end

module SingleInvoice
    class Client
        include HTTParty
        #debug_output $stdout

        attr_accessor :account_key, :api_uri, :coverage_key
        attr_reader :environment

        def initialize(options = {})
            self.account_key, self.coverage_key = options.values_at(:account_key, :coverage_key)

            self.environment ||= 'Sandbox'
            self.environment = options[:environment] if options[:environment]
        end

        def environment=(environment)
            @environment = environment
            self.api_uri = (environment == 'Production') ? 'https://api.single-invoice.co/v2.0' : 'https://api-demo.single-invoice.co'
            @environment
        end

        def get(url, if_none, options = {}, api_key = 'Coverage')
            result = handle_result self.class.get(self.api_uri + '/v2.0' + url, get_options(options, api_key))
            result.code == 404 ? if_none : result
        end

        def post(url, options = {}, api_key = 'Coverage')
            handle_result self.class.post(self.api_uri + '/v2.0' + url, get_options(options, api_key))
        end

        def put(url, options = {}, api_key = 'Coverage')
            handle_result self.class.put(self.api_uri + '/v2.0' + url, get_options(options, api_key))
        end

        def delete(url, options = {}, api_key = 'Coverage')
            handle_result self.class.delete(self.api_uri + '/v2.0' + url, get_options(options, api_key))
        end

        def get_options(options, api_key)
            options.merge(
                headers: { 'apikey' => api_key == 'Coverage' ? coverage_key : account_key },
                format: :json
            )
        end

        def handle_result(result)
            if [400, 401, 408, 409].include?(result.code)
                raise "[SingleInvoice] #{result['message']} (status code: #{result.code}" + (result['url'] ? ", url: #{result['url']}" : '') + ')'
            end

            result
        end
    end
end