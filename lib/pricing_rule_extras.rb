module PricingRuleExtras
  
  # Here are some helper methods not needed, but helpful for syntactic sugar
  def buy_x_get_y_free x, y
    self.condition = lambda {|items| items.size >= x }
    self.discount = lambda {|items| y * items.first.price }
  end
  
  def buy_more_than_x_get_y_off_each x, y
    self.condition = lambda {|items| items.size >= x }
    self.discount = lambda { |items|  y * items.size }
  end
  
  def free
    self.condition = lambda {|items| true }
    self.discount = lambda { |items|  items.first.price * items.size }
  end
end