require './loan_allocation_helper'
class LoanAllocation
  include LoanAllocationHelper

  attr_accessor :investors, :loans, :default_risk_bands

  def initialize(investors, loans, default_risk_bands)
    @investors = investors
    @loans = loans
    @default_risk_bands = default_risk_bands
  end

  # Allocate loans to investors testing
  def validate_and_allocate_loans
    allocated_loans = {}
    loans.each do |loan|
      allocated = false
      iterate_investors(loan, investors, allocated_loans, allocated)
      next unless allocated # If loan cannot be allocated to any investor, skip it
    end; allocated_loans
  end
end

# Sample data for testing
investors = [
  { name: 'Bob', category: ['property'], risk_band: nil, max_investment: 2000,
    property_percentage: 1 },
  { name: 'Susan', category: %w[property retail], risk_band: nil, max_investment: 2000,
    property_percentage: 1 },
  { name: 'George', category: [], risk_band: 'A', max_investment: 2000, property_percentage: 1 },
  { name: 'Helen', category: ['property'], risk_band: nil, max_investment: 8000,
    property_percentage: 0.4 },
  { name: 'Jamie', category: ['property'], risk_band: '>A', max_investment: 8000,
    property_percentage: 1 }
]

loans = [
  { id: 1, category: 'property', risk_band: 'A', amount: 6000 },
  { id: 2, category: 'retail', risk_band: 'B', amount: 2000 },
  { id: 3, category: 'property', risk_band: 'B', amount: 3000 },
  { id: 4, category: 'retail', risk_band: 'C', amount: 4000 },
  { id: 5, category: 'medical', risk_band: 'A', amount: 2000 },
  { id: 6, category: 'property', risk_band: 'C', amount: 1000 },
  { id: 7, category: 'property', risk_band: 'A+', amount: 6000 }
]
# Assigning values to risk bands, A+ holding highest risk value, c being lowest
default_risk_bands = ['A+', 'A', 'B', 'C'].zip([4, 3, 2, 1]).to_h
# Allocate loans to investors
allocation = LoanAllocation.new(investors, loans, default_risk_bands).validate_and_allocate_loans

# Print allocation
allocation.each do |investor, loans|
  puts "#{investor}:"
  loans.each { |loan| puts "  Loan #{loan[:id]} - £#{loan[:amount]}" }
end
