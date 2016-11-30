module SingleInvoice
    class Coverage
        attr_accessor :client, :id, :price, :price_currency, :status, :rejected_at, :rejected_by, :rejection_reason, :activated_at, :invoice

        def initialize(options, client = SingleInvoice)
            self.client = client
            update_from_options!(options)
            get_quote unless id
        end

        def self.from_api_result(result, instance = nil, client = SingleInvoice)
            return nil if result.nil?

            options = {
                id:               result['id'],
                price:            result['coverage']['coverPrice'],
                price_currency:   result['coverage']['currency'],
                status:           result['status'],
                rejected_at:      result['coverage']['rejectedAt'] ? Time.iso8601(result['coverage']['rejectedAt']) : nil,
                rejected_by:      result['rejectedBy'] || nil,
                rejection_reason: result['rejectionReason'] || nil,
                activated_at:     result['coverage']['activatedAt'] ? Time.iso8601(result['coverage']['activatedAt']) : nil,
                seller_id:        result['sellerId'],
                buyer_id:         result['buyerId'],
                amount:           result['invoice']['Amount'],
                currency:         result['invoice']['Currency'],
                issued_at:        result['invoice']['IssuedAt'] ? Time.iso8601(result['invoice']['IssuedAt']) : nil,
                due_at:           result['invoice']['DueAt'] ? Time.iso8601(result['invoice']['DueAt']) : nil
            }

            if instance
                instance.update_from_options!(options)
            else
                instance = self.new(options)
            end

            instance
        end

        def self.all(status = nil, from = nil, to = nil, page = nil, client = SingleInvoice)
            query          = {}
            query[:status] = status       unless status.nil?
            query[:from]   = from.iso8601 unless from.nil?
            query[:to]     = to.iso8601   unless to.nil?
            query[:page]   = page         unless page.nil?

            client.get('/coverage', [], query: query).map{|result| from_api_result(result, nil, client)}
        end

        def self.find(id, client = SingleInvoice)
            from_api_result(client.get("/coverage/#{id}", nil), nil, client)
        end

        def update_from_options!(options)
            self.id, self.price, self.price_currency, self.status, self.rejected_at, self.rejected_by, self.rejection_reason, self.activated_at = options.values_at(
                :id, :price, :price_currency, :status, :rejected_at, :rejected_by, :rejection_reason, :activated_at
            )

            self.invoice = SingleInvoice::slice_hash(options, :seller_id, :buyer_id, :amount, :currency, :issued_at, :due_at)
        end

        def activate
            self.class.from_api_result(client.put("/coverage/#{id}/activate"), self, client)
        end

        def cancel
            Transaction.from_api_result(client.delete("/coverage/#{id}/cancel"), nil, client)
        end

        def declare_late(new_date = nil)
            body = new_date.nil? ? {} : { newDate: new_date.iso8601 }
            Transaction.from_api_result(client.put("/coverage/#{id}/late", body: body), nil, client)
        end

        def file_claim
            Transaction.from_api_result(client.post("/coverage/#{id}/claim"), nil, client)
        end

        def reject
            self.class.from_api_result(client.put("/coverage/#{id}/reject"), self, client)
        end

        def settle
            Transaction.from_api_result(client.put("/coverage/#{id}/settle"), client)
        end

        private

        def get_quote
            result = client.post('/coverage', {
                body: {
                    sellerid: invoice[:seller_id],
                    buyerid:  invoice[:buyer_id],
                    invoice: {
                        issuedAt: invoice[:issued_at].iso8601,
                        dueAt:    invoice[:due_at].iso8601,
                        amount:   invoice[:amount],
                        currency: invoice[:currency]
                    }
                }
            })

            self.class.from_api_result(result, self, client)
        end
    end
end