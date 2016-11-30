module SingleInvoice
    class CompanySearchService
        attr_accessor :client, :code, :label

        def initialize(code, label, client = SingleInvoice)
            self.client = client
            self.code   = code
            self.label  = label
        end

        def self.from_api_result(result, instance = nil, client = SingleInvoice)
            options = {
                code:  result['IdentifierCode'],
                label: result['IdentifierLabel']
            }

            if instance
                instance.code  = options[:code]
                instance.label = options[:label]
            else
                instance = self.new(options[:code], options[:label], client)
            end

            instance
        end

        def self.all(client = SingleInvoice)
            client.get('/lookups/services', []).map{|result| from_api_result(result, nil, client)}
        end
    end 
end