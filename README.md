Checkout by wolas
=================

* Checkout fucntionality with a fully manageable discount system
* each pricing_rule has a code, matched to every item to see wether it applies, the resulting items are called selected_items
* Rules are defined by two parameters:
  * Condition: which is a function over selected_items determining wether the discount can be aplied or not. Return true or false
  * Discount: again, a function over seleted_items which determines the amount to be disocunted. returns an Integer
* Helper methods are present to provide more human like coding. These include buy_more_than_x_get_y_off_each and buy_x_get_y_free
* The main effort has been to provide a fully customizable discount system paired with beautifull syntax. 


Considerations
----

I wanted to exted the PricingRule class by allowing one instance to work on multiple codes and have multiple conditions.
But I think that the same functionality is achieved by having multiple PricingRule instances with the same code. This
also makes for easier understanding and using. 


### Example

``` ruby
    voucher = Item.new("Cabify Voucher", 5, "VOUCHER")
    tshirt = Item.new("Cabify T-Shirt", 20, "TSHIRT")
    mug = Item.new("Cafify Coffee Mug", 7.5, "MUG")
    
    pricing_voucher = PricingRule.new("VOUCHER")
    pricing_voucher.buy_x_get_y_free 2, 1
    
    pricing_tshirt = PricingRule.new("TSHIRT")
    pricing_tshirt.buy_more_than_x_get_y_off_each 3, 1.00
    
    checkout = Checkout.new
    checkout.scan voucher
    checkout.scan voucher
    checkout.scan tshirt
    checkout.scan mug
    checkout.scan tshirt
    checkout.scan tshirt
    
    checkout.total
```

or, if you rpefer to code your own discounts, just set the condition and discount. For example:

``` ruby
    voucher = Item.new("Cabify Voucher", 5, "VOUCHER")
    tshirt = Item.new("Cabify T-Shirt", 20, "TSHIRT")
    mug = Item.new("Cafify Coffee Mug", 7.5, "MUG")
    
    pricing_voucher = PricingRule.new("VOUCHER")
    
    # you must buy more than 2 and less than 10 to get the discount
    pricing_voucher.condition = lambda do |items|
      items.size > 2 and items.size < 10
    end
    
    # you get a total discount of 3, independent of number of vouchers bought
    pricing_voucher.discount = lambda do |items|
      3
    end
    
```


Requirements
----

* Production - Ruby
* Testing - Rspec