class Product < ActiveRecord::Base
  validates_presence_of :name, :price, :delivery_date
end
