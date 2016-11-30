module SingleInvoice
    class Transaction
        attr_accessor :client, :id, :initiated_at, :documents

        def initialize(id, client = SingleInvoice)
            self.client    = client
            self.id        = id
            self.documents = []
        end

        def self.from_api_result(result, instance = nil, client = SingleInvoice)
            instance              = self.new(result['transactionId'], client) unless instance
            instance.initiated_at = result['initiatedAt'].nil? ? nil : Time.iso8601(result['initiatedAt'])
            instance.documents    = result['documents'].nil?   ? []  : result['documents']
            instance
        end
    end
end