class Transaction < ApplicationRecord
  self.primary_key = 'transaction_id'

  validates :transaction_id, presence: true
  validates :merchant_id, presence: true
  validates :user_id, presence: true
  validates :card_number, presence: true
  validates :transaction_date, presence: true
  validates :transaction_amount, presence: true
  validates :has_cbk, presence: true
end
