class LoanAllocation
  attr_accessor :investors, :loans, :default_risk_bands

  def initialize(investors, loans, default_risk_bands)
    @investors = investors
    @loans = loans
    @default_risk_bands = default_risk_bands
  end

  def allocate_loans
    # Allocate loans to investors
    allocated_loans = {}
    loans.each do |loan|
      allocated = false
      investors.each do |investor|
        allocated_loans[investor[:name]] ||= []
        # Check if investor's investment is more than the loan amount
        if investor[:max_investment] >= loan[:amount]
          # Check if investor's category matches with loan category
          if investor[:category].include? loan[:category]
              # Check and assign if satisfies percentage criteria
              if allocate_loans_by_percentage?(investor, loan, allocated_loans, allocated)
                break
              elsif !investor[:risk_band].nil?
                # Allocate loans by risk band
                allocate_loans_by_risk_band(investor, loan, allocated_loans, allocated,
                  default_risk_bands)
                break
              else
                # Allocate loans if investor category matches with loan category
                assign_loans(investor, loan, allocated_loans, allocated)
                break
              end
          elsif investor[:risk_band] == loan[:risk_band]
              # Allocate loans if investor risk band equals with loan risk band
              assign_loans(investor, loan, allocated_loans, allocated)
              break
          end
        end
      end
      # If loan cannot be allocated to any investor, skip it
      next unless allocated
    end
    allocated_loans
  end

  # Method for checking and assign if satisfies percentage criteria
  def allocate_loans_by_percentage?(investor, loan, allocated_loans, allocated)
    if calculate_percentage(allocated_loans) > investor[:property_percentage]
        assign_loans(investor, loan, allocated_loans, allocated)
        return true
    end
    return false
  end
  # Method for calculate property loan percentage
  def calculate_percentage(allocated_loans, category_type = "property")
    allocated_loan_values = allocated_loans.values.flatten
    (allocated_loan_values.count {|l| l[:category] == category_type} + 1) / (allocated_loan_values.count.to_f + 1)
  end

  # Method for Allocating loans by risk band
  def allocate_loans_by_risk_band(investor, loan, allocated_loans, allocated,
                  default_risk_bands)
    investor_risk_val = get_risk_band_val(default_risk_bands, investor[:risk_band][-1])
    loan_risk_val = get_risk_band_val(default_risk_bands, loan[:risk_band])

    case investor[:risk_band].chop
      when '>'
        if loan_risk_val > investor_risk_val
          assign_loans(investor, loan, allocated_loans, allocated)
        end
      when '<'
        if loan_risk_val < investor_risk_val
          assign_loans(investor, loan, allocated_loans, allocated)
        end
      when '<='
        if loan_risk_val <= investor_risk_val
          assign_loans(investor, loan, allocated_loans, allocated)
        end
      when '>='
        if loan_risk_val >= investor_risk_val
          assign_loans(investor, loan, allocated_loans, allocated)
        end
    end
  end

  # Method for allocating loans to investor
  def assign_loans(investor, loan, allocated_loans, _allocated)
    allocated_loans[investor[:name]] << loan
    investor[:max_investment] -= loan[:amount]
    allocated = true
  end

  # Method for getting risk band value from default risk bands
  def get_risk_band_val(default_risk_bands, risk_band_val)
    default_risk_bands.select{|r,v| r == risk_band_val}.values.first
  end
end

# Sample data
investors = [
  { name: 'Bob', category: ['property'], risk_band: nil, max_investment: 2000,
    property_percentage: 1 },
  { name: 'Susan', category: %w[property retail], risk_band: nil, max_investment: 2000,
    property_percentage: 1 },
  { name: 'George', category: [], risk_band: 'A', max_investment: 2000, property_percentage: 1 },
  { name: 'Helen', category: ['property'], risk_band: nil, max_investment: 8000,
    property_percentage: 0.4 },
  { name: 'Jamie', category: ['property'], risk_band: '>A', max_investment: 8000,
    property_percentage: 1 },
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
default_risk_bands = ['A+','A','B','C'].zip([4,3,2,1]).to_h
# Allocate loans to investors
allocation = LoanAllocation.new(investors, loans, default_risk_bands).allocate_loans

# Print allocation
allocation.each do |investor, loans|
  puts "#{investor}:"
  loans.each { |loan| puts "  Loan #{loan[:id]} - £#{loan[:amount]}" }
end
