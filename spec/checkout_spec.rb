require 'checkout'
require 'item'
require 'pricing_rule'

RSpec.describe do
  
  before :each do 
    @voucher = Item.new("Cabify Voucher", 5, "VOUCHER")
    @tshirt = Item.new("Cabify T-Shirt", 20, "TSHIRT")
    @mug = Item.new("Cafify Coffee Mug", 7.5, "MUG")
    
    @pricing_rule1 = PricingRule.new("VOUCHER")
    @pricing_rule1.condition = lambda {|items| items.size >= 2 }
    @pricing_rule1.discount = lambda {|items| (items.size/2) * 5 }
    
    @pricing_rule2 = PricingRule.new("TSHIRT")
    @pricing_rule2.condition = lambda {|items| items.size >= 3 }
    @pricing_rule2.discount = lambda {|items| items.size }
    
    @pricing_rule3 = PricingRule.new("MUG")
  end
  
  
  describe Checkout do
    
    before :each do 
      @checkout = Checkout.new
    end
  
    describe "initially" do
      it "should have an empty set of items" do
        expect(@checkout.items).to be_empty
      end
    end
    
    describe 'scan' do
      it 'should add items internally' do
        @checkout.scan(@voucher)
        expect(@checkout.items).to include(@voucher)
      end
    end
    
    describe 'total' do
      
      before :each do 
        @checkout.pricing_rules = [@pricing_rule1, @pricing_rule2]
      end
      
      
      it 'Items: VOUCHER, TSHIRT, MUG' do
        @checkout.scan @voucher
        @checkout.scan @tshirt
        @checkout.scan @mug
        
        expect(@pricing_rule1.discount_on(@checkout.items)).to eq(0)
        expect(@pricing_rule2.discount_on(@checkout.items)).to eq(0)
        expect(@checkout.total).to eq(32.5)
      end
      
      it 'Items: VOUCHER, TSHIRT, VOUCHER' do
        @checkout.scan @voucher
        @checkout.scan @tshirt
        @checkout.scan @voucher
        
        expect(@pricing_rule1.discount_on(@checkout.items)).to eq(5)
        expect(@pricing_rule2.discount_on(@checkout.items)).to eq(0)
        expect(@checkout.total).to eq(25)
      end
      
      it 'Items: TSHIRT, TSHIRT, TSHIRT, VOUCHER, TSHIRT' do
        @checkout.scan @tshirt
        @checkout.scan @tshirt
        @checkout.scan @tshirt
        @checkout.scan @voucher
        @checkout.scan @tshirt
        
        expect(@pricing_rule1.discount_on(@checkout.items)).to eq(0)
        expect(@pricing_rule2.discount_on(@checkout.items)).to eq(4)
        expect(@checkout.total).to eq(81)
      end
      
      it 'Items: VOUCHER, TSHIRT, VOUCHER, VOUCHER, MUG, TSHIRT, TSHIRT' do
        @checkout.scan @voucher
        @checkout.scan @tshirt
        @checkout.scan @voucher
        @checkout.scan @voucher
        @checkout.scan @mug
        @checkout.scan @tshirt
        @checkout.scan @tshirt
        
        expect(@pricing_rule1.discount_on(@checkout.items)).to eq(5)
        expect(@pricing_rule2.discount_on(@checkout.items)).to eq(3)
        expect(@checkout.total).to eq(74.5)
      end
      
    end
  end
  
  describe PricingRule do
    before :each do 
      @items = [@voucher, @voucher, @mug]
    end
  
    describe 'condition' do
    
      it 'should return true if condition over items are met' do
        expect(@pricing_rule1.conditions_met?(@items)).to be(true)
      end
    
      it 'should return false if condition over items are not met' do
        expect(@pricing_rule1.conditions_met?([])).to be(false)
      end
    
      it 'should only work on correctly coded items' do
        expect(@pricing_rule1.conditions_met?([@voucher, @tshirt])).to be(false)
      end
    
    end
  
    describe 'discount' do
    
      it 'should be applied correctly' do
        expect(@pricing_rule1.discount_on(@items)).to be(5)
      end
      
      it 'should only be applied to items with same code' do
        @items = [@voucher, @voucher, @tshirt, @tshirt, @tshirt]
        expect(@pricing_rule1.discount_on(@items)).to eq(5)
        expect(@pricing_rule2.discount_on(@items)).to eq(3)
      end
    
    end
    
    describe 'helpers' do
      
      before :each do
        @pricing_rule1 = PricingRule.new("VOUCHER")
        @pricing_rule2 = PricingRule.new("TSHIRT")
      end
      
      describe '.buy_x_get_y_free' do
        
        it 'should work for "buy 2 get 1" on vouchers' do
          @items = [@voucher, @voucher, @tshirt, @tshirt, @tshirt]
          @pricing_rule1.buy_x_get_y_free 2, 1
          expect(@pricing_rule1.discount_on(@items)).to eq(5)
        end
        
        it 'should work for "buy 3 get 2" on vouchers' do
          @items = [@voucher, @voucher, @voucher, @voucher]
          @pricing_rule1.buy_x_get_y_free 3, 2
          expect(@pricing_rule1.discount_on(@items)).to eq(10)
        end
        
        it 'should not take into account vouchers which dont make it to the x cut' do
          @items = [@voucher, @voucher, @voucher]
          @pricing_rule1.buy_x_get_y_free 2, 1
          expect(@pricing_rule1.discount_on(@items)).to eq(5)
        end
        
        it 'should work on odd number of vouchers' do
          @items = [@voucher, @voucher, @voucher, @voucher]
          @pricing_rule1.buy_x_get_y_free 3, 1
          expect(@pricing_rule1.discount_on(@items)).to eq(5)
        end
      end
      
      describe '.buy_more_than_x_get_y_off_each' do
        
        it 'should work for "buy more than 3, get $5.00 off on mugs"' do
          @items = [@mug, @mug, @mug]
          @pricing_rule3.buy_more_than_x_get_y_off_each 3, 5.00
          expect(@pricing_rule3.discount_on(@items)).to eq(15)
        end
        
        it 'should work for all mugs other than the x required' do
          @items = [@mug, @mug, @mug, @mug, @mug]
          @pricing_rule3.buy_more_than_x_get_y_off_each 3, 5.00
          expect(@pricing_rule3.discount_on(@items)).to eq(25)
        end
      end
      
      describe 'free' do
        it 'should make the discount total on vouchers' do
          @items = [@tshirt, @tshirt, @tshirt, @voucher, @voucher]
          @pricing_rule1.free
          expect(@pricing_rule1.discount_on(@items)).to eq(10)
        end
        
        it 'should make the discount total on tshirts' do
          @items = [@tshirt, @tshirt, @tshirt, @voucher, @voucher]
          @pricing_rule2.free
          expect(@pricing_rule2.discount_on(@items)).to eq(60)
        end
      end
      
    end
  end
end