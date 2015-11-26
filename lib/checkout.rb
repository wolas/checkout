class Checkout
  
  attr_accessor :pricing_rules, :items
  
  def initialize pricing_rules= [], items = []
    @pricing_rules, @items = pricing_rules, items
  end
  
  def scan item
    @items << item
  end
  
  def total
    # discount is the sum of all pricing_rule discounts on all items
    discount = @pricing_rules.map{|pr| pr.discount_on(@items) }.inject(:+)
    # subtotal is the sum of all prices in items
    subtotal = @items.map(&:price).inject(:+)
    subtotal - discount
  end
end