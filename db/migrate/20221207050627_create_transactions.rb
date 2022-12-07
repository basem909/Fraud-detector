class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.integer :transaction_id
      t.integer :merchant_id
      t.integer :user_id
      t.integer :card_number
      t.date :transaction_date
      t.decimal :transaction_amount, default: nil, precision: 8, scale: 2
      t.integer :device_id
      t.boolean :has_cbk, :default => false

      t.index :transaction_id, unique: true

      t.timestamps
    end
  end
end
