allocate_loans method of LoanAllocation class in loan_allocation.rb expect
investors, loans and default_risk_bands as inputs

investors hash holds investor details like name, category array, risk_band, max_investment and property_percentage

    category will have investors intersted category and it may have multiple values.

    risk_band may have risk band any one value from A+, A, B, C, A+ is having greater risk and C being lower risk or nil.

    max_investment holds maximum investment amount value of investor.

    property_pecentage holds the percentage value, by default 100% which is 1.

    sample: { name: 'Susan', category: %w[property retail], risk_band: nil, max_investment: 2000, property_percentage: 1 }

Loans hash holds id, category, risk_band and amount

    id is unique value which identifies loan.
    category is loan category type. ex: Property
    risk_band holds sigle value from [A+, A, B, C], A+ is having greater risk and C being lower risk.

default_risk_bands is the computed hash from loans risk_band attribute, assigning numeric value to each risk band
    A+ => 4, A => 3, B => 2, c => 1

This class provides the solution for Part I and Part II. At first Part1 is implemented then the same class extended to provide solution for Part II.

From line number 22 to 28 holds the solution for Part II.

Thought Process:

  In the investors hash it self,i have provided investor choice of category, risk band and maximum investment amount and property percentage.

  At first code is iteratating thru loans hash, and for each loan it is iterating investor hash.

  If an investor is alloted to a loan, then it is marking as loan as alloted, so that another investor can't be allotted to the same loan.

  For each loan code is checking whether investor investment should be more than loan amount

  As a next step, if investor category is same as loan category and the loan amount is less than the investor investment, then that particular loan is allotted to that investor.

  Next,if investor category matches and if that investor has percentage criteria, then validating the investor persentage and alloting that loan to that investor.

  If investor has any risk band criteria like <, >, <= and => then validating investor risk band criteria against loan risk band and alloting that loan to that investor.

  If investor risk band is similar to the loan risk band, then alloting that loan to that investor.

