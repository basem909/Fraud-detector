class TransactionsController < ApplicationController
  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.transaction_date = DateTime.now

    if repetition(@transaction) or daily_limit(@transaction) or cbk_history(@transaction)
      render json: { transaction_id: @transaction.transaction_id , recommendation:'Reject'} 
      @transaction.save
    else
      render json: { transaction_id: @transaction.transaction_id , recommendation:'Approve'} 
      @transaction.save
    end
  end
  
  private

  def repetition(transaction)
    previous_transaction = Transaction.where(user_id: transaction.user_id).last
    return false unless previous_transaction

    new_date = transaction.transaction_date
    previous_transaction_date = previous_transaction.transaction_date

    time_difference = (new_date - previous_transaction_date) / 1.minutes

    return true if time_difference < 2
    return false 
  end

  def daily_limit(transaction)
    daily_transactions = Transaction.where(user_id: transaction.user_id).where(transaction_date: Date.today.all_day)
    return false unless daily_transactions

    daily_payment_made = daily_transactions.sum(:transaction_amount)

    return true if daily_payment_made >= 5000
    return false
  end

  def cbk_history(transaction)
    chargebacks_history = Transaction.where(user_id: transaction.user_id ).where(has_cbk: true).count

    return true if chargebacks_history > 0
    return false
  end
  def transaction_params
     params.permit(:transaction_id, :merchant_id, :user_id, :card_number, :transaction_amount, :device_id, :has_cbk)
  end
end
