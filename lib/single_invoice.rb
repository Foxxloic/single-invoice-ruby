require 'forwardable'
require 'single_invoice/client'

module SingleInvoice
    class << self
        extend Forwardable

        def_delegators :default_client, *Client.instance_methods

        def slice_hash(hash, *keys)
            Hash[[keys, hash.values_at(*keys)].transpose]
        end

        def default_client
            @default_client ||= SingleInvoice::Client.new
        end
    end
end

require 'single_invoice/company_search_service'
require 'single_invoice/company'
require 'single_invoice/country'
require 'single_invoice/coverage'
require 'single_invoice/transaction'
require 'single_invoice/version'

SingleInvoice.account_key  = 'y5V3kBZsxBJiLkaOkkYUTKDpbYslblKlyBxrBILTLA7551pS9sdCe2RsSMBF1'
SingleInvoice.coverage_key = 'yS2QNGoISuK0b2nYOoBDwVliBLWc2lEzDVWzk3MbC5Tpl29Z9zAYkpuggEwtwo'