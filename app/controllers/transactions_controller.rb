class TransactionsController < ApplicationController
  def create

  end
  
  private
  def transaction_params
     params.permit(:transaction_id, :merchant_id, :user_id, :card_number, :transaction_date, :transaction_amount, )
  end
end
