module SingleInvoice
    class Company
        attr_accessor :client, :id, :name, :address, :phone_number, :legal_form_code

        def initialize(id, client = SingleInvoice)
            self.client = client
            self.id     = id
        end

        def self.from_api_result(result, instance = nil, client = SingleInvoice)
            return nil if result.nil?

            instance                 = self.new(result['Id'], client) unless instance
            instance.name            = result['Name']
            instance.address         = result['Address'] ? address_from_api_result(result['Address']) : nil
            instance.phone_number    = result['PhoneNumber']
            instance.legal_form_code = result['LegalFormCode']
            instance
        end

        def self.find(id, client = SingleInvoice)
            from_api_result(client.get("/transactor/#{URI.encode(id)}", nil), nil, client)
        end

        def self.find_by_code(code, code_system, country_code, client = SingleInvoice)
            from_api_result(client.get("/transactor/#{URI.encode(country_code)}/#{URI.encode(code_system)}/#{URI.encode(code)}", nil), nil, client)
        end

        def self.find_by_name(name, country_code, client = SingleInvoice)
            client.get("/transactor/#{URI.encode(country_code)}/#{URI.encode(name)}", []).map{|result| from_api_result(result, nil, client)}
        end

        def coverages(status = nil, from = nil, to = nil, page = nil)
            get_coverages(false, status, from, to, page)
        end

        def aged_coverages(status = nil, from = nil, to = nil, page = nil)
            get_coverages(true, status, from, to, page)
        end

    private

        def self.address_from_api_result(result)
            {
                street_name:   result['StreetName'],
                street_number: result['StreetNumber'],
                city:          result['City'],
                state_code:    result['StateCode'],
                postal_code:   result['PostCode'],
                country_code:  result['CountryCode']
            }
        end

        def get_coverages(aged, status, from, to, page)
            query          = {}
            query[:status] = status       unless status.nil?
            query[:from]   = from.iso8601 unless from.nil?
            query[:to]     = to.iso8601   unless to.nil?
            query[:page]   = page         unless page.nil?

            client.get("/transactors/#{id}/coverages" + (aged ? '/aged' : ''), [], query: query)
        end
    end
end