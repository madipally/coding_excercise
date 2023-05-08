module LoanAllocationHelper
  # Method for iterating investors against each loan and assigning
  def iterate_investors(loan, investors, allocated_loans, allocated)
    investors.each do |investor|
      allocated_loans[investor[:name]] ||= []
      if compare_amounts?(investor[:max_investment], loan[:amount]) && (investor[:category].include? loan[:category]) # Check if investor's category matches with loan category
        allocate_loans_by_percentage_or_risk(investor, loan, allocated_loans, allocated);break
      elsif compare_amounts?(investor[:max_investment], loan[:amount]) && investor[:risk_band] == loan[:risk_band]
        assign_loans(investor, loan, allocated_loans, allocated);break # Allocate loans if investor risk band equals with loan risk band
      end
    end; allocated_loans
  end

  # Method for comparing investor's amount against loan amount
  def compare_amounts?(investor_amount, loan_amount)
    investor_amount >= loan_amount
  end

  # Method for allocate loans / percentage

  def allocate_loans_by_percentage_or_risk(investor, loan, allocated_loans, allocated)
    if allocate_loans_by_percentage?(investor, loan, allocated_loans, allocated) # Check and assign if satisfies percentage criteria
    elsif !investor[:risk_band].nil?
      allocate_loans_by_risk_band(investor, loan, allocated_loans, allocated, default_risk_bands) # Allocate loans by risk band
    else
      assign_loans(investor, loan, allocated_loans, allocated) # Allocate loans if investor category matches with loan category
    end
  end

  # Method for checking and assign if satisfies percentage criteria
  def allocate_loans_by_percentage?(investor, loan, allocated_loans, allocated)
    if calculate_percentage(allocated_loans) > investor[:property_percentage]
      assign_loans(investor, loan, allocated_loans, allocated)
      return true
    end
    false
  end

  # Method for calculate property loan percentage
  def calculate_percentage(allocated_loans, category_type = 'property')
    allocated_loan_values = allocated_loans.values.flatten
    (allocated_loan_values.count { |l| l[:category] == category_type } + 1) / (allocated_loan_values.count.to_f + 1)
  end

  # Method for Allocating loans by risk band
  def allocate_loans_by_risk_band(investor, loan, allocated_loans, allocated,
                                  default_risk_bands)
    investor_risk_val = get_risk_band_val(default_risk_bands, investor[:risk_band][-1])
    loan_risk_val = get_risk_band_val(default_risk_bands, loan[:risk_band])
    case investor[:risk_band].chop
    when '>'
      assign_loans(investor, loan, allocated_loans, allocated) if loan_risk_val > investor_risk_val
    when '<'
      assign_loans(investor, loan, allocated_loans, allocated) if loan_risk_val < investor_risk_val
    when '<='
      assign_loans(investor, loan, allocated_loans, allocated) if loan_risk_val <= investor_risk_val
    when '>='
      assign_loans(investor, loan, allocated_loans, allocated) if loan_risk_val >= investor_risk_val
    else
      puts "Invalid choice"
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
    default_risk_bands.select { |r, _v| r == risk_band_val }.values.first
  end
end

