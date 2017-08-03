module MapperHelper

  def set_lines_currency(output, base_currency)
    output[:lines].each do |line|
      line[:unit_price].merge!(currency: base_currency)
    end

    output
  end

  def get_rate_from_country(country_tax_rate)
    (country_tax_rate * 100) || 0
  end
end
