# SingleInvoice

Insurance for B2B invoices via SingleInvoice's official ruby gem

## Installation

Add single_invoice to your Gemfile, and then run `bundle install`

```ruby
gem 'single_invoice'
```

or install via gem

    $ gem install single_invoice

## Configuration

Register a developer account on Single-Invoice.co then set your API credentials on the SingleInvoice class:
```ruby
SingleInvoice.account_key  = 'your-single-invoice-account-key'
SingleInvoice.coverage_key = 'your-single-invoice-coverage-key'
```

In Rails this would be added to `config/initializers/single_invoice.rb`

Alternatively, you can instantiate clients with their own API credentials. This is useful for apps using more than one set of credentials. Every method discussed below must then be called with the client as the last argument:

```ruby
client = SingleInvoice::Client.new('your-account-key', 'your-coverage-key')
company = SingleInvoice::Company.find('6d568a15-f99c-4b4b-9143-fbda98b0b32e', client)
```

## Objects (and their properties)
```ruby
# SingleInvoice::Company 
  @id="2ab73aae-4223-422c-85ea-ce3d39b5e260",
  @name="EULER HERMES FRANCE",
  @address={:street_name=>"PLACE DES SAISONS", :street_number=>"1", :city=>"PARIS LA DEFENSE CEDEX", :state_code=>"92", :postal_code=>"92048", :country_code=>"FR"},
  @phone_number="0184115050",
  @legal_form_code="SA16"

# SingleInvoice::CompanySearchService
  @code="SIRET",
  @label="SIRET number"

# SingleInvoice::Country
  @code="FR",
  @label="France"

# SingleInvoice::Coverage
  @id="ac3e4568-689a-476b-a8e0-e966d9c2dc24",
  @price=0.0,
  @price_currency="EUR",
  @status="Rejected",
  @rejected_at=2016-11-29 21:30:47 UTC,
  @rejected_by="Single Invoice",
  @rejection_reason="Service temporarily unavailable",
  @activated_at=nil,
  @invoice={:seller_id=>"2ab73aae-4223-422c-85ea-ce3d39b5e260", :buyer_id=>"fbe371c7-4db6-43d8-9164-f38350677c94", :amount=>1000.42, :currency=>"EUR", :issued_at=>2016-08-30 00:00:00 UTC, :due_at=>2016-10-30 00:00:00 UTC}
```

## Company Lookup
```ruby
# Find company by name
name      = 'Euler Hermes'
country   = 'FR'
companies = SingleInvoice::Company.find_by_name(name, country)

pp companies # [#<SingleInvoice::Company>, ...]

# Find company by code
code     = '41773899400058'
system   = 'SIRET'
country  = 'FR'
company1 = SingleInvoice::Company.find_by_code(code, system, country)

pp company1 # #<SingleInvoice::Company> or nil

# Look up existing company
company_id = '2ab73aae-4223-422c-85ea-ce3d39b5e260'
company2   = SingleInvoice::Company.find(company_id)

pp company2 # #<SingleInvoice::Company> or nil
```

## Invoice Insurance
```ruby
# Get a quote for new coverage (all attributes required)
quote = SingleInvoice::Coverage.new(
    seller_id: '2ab73aae-4223-422c-85ea-ce3d39b5e260',
    buyer_id:  'fbe371c7-4db6-43d8-9164-f38350677c94',
    amount:    1000.42,
    currency:  'eur', # usd, eur, etc. (ISO 4217)
    issued_at: Date.new(2016, 8, 30),
    due_at:    Date.new(2016, 10, 30)
)

if quote.status == 'Rejected'
  print 'SingleInvoice cannot insure this invoice'
elsif quote.status == 'Pending'
  if quote.price > 100 && quote.price_currency == 'eur'
    quote.reject # reject the quote if the user doesn't want insurance
  else
    quote.activate # activate the coverage, insuring the invoice
  end
end
```

## Coverage Lifecycle
```ruby
# Look up existing coverage (or quote)
coverage_id = 'ac3e4568-689a-476b-a8e0-e966d9c2dc24'
coverage    = SingleInvoice::Coverage.find(coverage_id)

pp coverage # #<SingleInvoice::Coverage> or nil

# Cancel coverage if it's no longer needed
coverage.cancel

# Settle coverage if the invoice is paid
coverage.settle

# Declare buyer late in paying covered invoice
coverage.declare_late

# File a claim against coverage
coverage.file_claim

# Direct end-user to documentation required for claim
pp coverage.documents # [...]
```

## Miscellaneous
```ruby
# List company code systems (for SingleInvoice::Company#find_by_code)
systems = SingleInvoice::CompanySearchService.all

pp systems # [#<SingleInvoice::CompanySearchService>, ...]
pp systems[42].id # e.g., SIRET, DUNS, etc.

# List country codes (ISO 3166-1 alpha-2; cacheable)
countries = SingleInvoice::Country.all

pp countries # [#<SingleInvoice::Country>, ...]
pp countries[42].id # e.g., UK, FR, US, etc.

status = 'Pending'
from   = Date.new(2016, 1, 1)
to     = Date.new(2016, 10, 10)
page   = 1

# List company's coverages (all arguments optional)
coverages = company1.coverages(status, from, to, page)

pp coverages # [#<SingleInvoice::Coverage>, ...]

# List company's aged coverages (all arguments optional)
coverages = company1.aged_coverages(status, from, to, page)

pp coverages # [#<SingleInvoice::Coverage>, ...]

# List coverages among all companies (all arguments optional)
coverages = SingleInvoice::Coverage.all(status, from, to, page)

pp coverages # [#<SingleInvoice::Coverage>, ...]
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

