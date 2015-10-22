class KardexPrice < ActiveRecord::Base
  default_scope {where(invalidate: false).order(:id)}

  belongs_to :kardex

  # Anula las entradas de los kardex
  def self.invalidate_kardex_prices
    update_all(invalidate: true)
  end

  def decrease_amount(amount)
    self.input_quantities = 0
    self.input_amount = 0
    balance = self.balance_quantities - amount
    if balance < 0
      balance = balance.abs
      self.output_quantities = self.balance_quantities
      self.balance_quantities = 0
      amount = balance
    else
      self.output_quantities = amount
      self.balance_quantities = balance
      amount = 0
    end
    self.output_amount = self.output_quantities * self.unit_cost
    self.balance_amount = self.balance_quantities * self.unit_cost
    amount
  end

  def sum_inputs(subarticle)
    self.input_quantities = 0
    subarticle.kardexes.each do |k|
      self.input_quantities += k.kardex_prices.sum(:input_quantities)
    end
    self.input_amount = self.input_quantities * self.unit_cost
  end

  def sum_outputs(subarticle)
    self.output_quantities = 0
    subarticle.kardexes.each do |k|
      self.output_quantities += k.kardex_prices.sum(:output_quantities)
    end
    self.output_amount = self.output_quantities * self.unit_cost
  end
end
