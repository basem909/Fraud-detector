# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'csv'

csv_text = File.read(Rails.root.join('lib', 'seeds', 'transactional-sample.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
csv.each do |row|
  t = Transaction.new
  t.transaction_id = row['transaction_id']
  t.merchant_id = row['merchant_id']
  t.user_id = row['user_id']
  t.card_number = row['card_number']
  t.transaction_date = row['transaction_date']
  t.transaction_amount = row['transaction_amount']
  t.device_id = row['device_id']
  t.has_cbk = row['has_cbk']
  t.save
  puts "#{t.merchant_id}, #{t.user_id} saved"
end

puts "There are now #{Transaction.count} rows in the transactions table"