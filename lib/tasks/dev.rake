namespace :dev do

  task rebuild: ["db:drop", "db:setup", :fake, "db:seed"]
  task fake: [:fake_product, :fake_user, :fake_order]

  task fake_product: :environment do
    puts "Create fake products for development"
    Product.destroy_all
    1000.times do
      Product.create!(
        name: FFaker::Name.first_name,
        description: FFaker::Lorem.paragraph,
        price: ( rand(500)+1 ) * 10,
        image: FFaker::Avatar.image
      )
    end
    puts "now you have #{Product.count} products record"
  end

  task fake_user: :environment do
    puts "Create fake users for development"
    User.destroy_all

    User.create!(email: "root@example.com", password: "12345678", role: "admin")
    puts "create default admin"

    10.times do |i|
      User.create!(
        email: FFaker::Internet.email,
        password: "12345678"
      )
    end
    puts "now you have #{User.count} user record"
  end

  task fake_order: :environment do
    puts "Create fake orders for development"
    Order.destroy_all
    Cart.destroy_all


    100.times do
      user = User.all.sample
      cart = Cart.create!

      # put product into cart
      rand(10).times do
        product = Product.all.sample
        cart.add_cart_item(product)
      end

      # checkout cart to order
      order = Order.new(
        sn: Time.now.to_i,
        user_id: user.id,
        amount: cart.subtotal,
        name: user.email.split("@").first,
        phone: FFaker::PhoneNumber.short_phone_number,
        address: FFaker::Address.street_address
      )
      order.add_order_items(cart)
      order.save!
      cart.destroy
    end
    puts "now you have #{Order.count} order record"
  end

end
