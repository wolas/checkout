require 'pricing_rule_extras'

class PricingRule < Struct.new(:code, :condition, :discount)
  
  include PricingRuleExtras
  
  def discount_on items
    # discount is 0 if conditions are not met
    return 0 unless conditions_met?(items)
    # if conditions are met, call discount lambda with list of items
    discount.call selected_items(items)
  end
  
  def conditions_met? items
    # conditions are specified in lambda and are only applied to selected_items
    condition.call selected_items(items)
  end
  
  private
  def selected_items items
    # selected items are ones which share the same code as self
    items.select{ |i| i.code == self.code }
  end
  
end

