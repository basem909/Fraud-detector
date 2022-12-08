class TransactionsController < ApplicationController
  
  def create
    # starting a new record based on the passed params
    @transaction = Transaction.new(transaction_params)
    # assign the current time to the record
    @transaction.transaction_date = DateTime.now


    # check fraud using the preset rules and reject the transaction in case of fraudental behavior
    if repetition(@transaction) or daily_limit(@transaction) or cbk_history(@transaction)
      render json: { transaction_id: @transaction.transaction_id , recommendation:'Reject'}
      @transaction.approve = false
    else
      # approve the transaction if the checks are passed successfully
      render json: { transaction_id: @transaction.transaction_id , recommendation:'Approve'}
      @transaction.approve = true
    end
    # save the record to the database so it can be revised after the check
    @transaction.save
  end
  
  private
  # check of repeatetive transaction in short period 
  # expecting the transaction object passed in the request
  def repetition(transaction)
    previous_transaction = Transaction.where(user_id: transaction.user_id).last
    return false unless previous_transaction # in case of the first transaction for this user

    new_date = transaction.transaction_date # the newly made transaction time stamp
    previous_transaction_date = previous_transaction.transaction_date # the most recent record before the new  made transaction time stamp

    # the difference between the 2 transactions turned into minutes
    time_difference = (new_date - previous_transaction_date) / 1.minutes 

    # time limit to enable making a new transaction
    @time_limit = 2

    # checking the rule of repeatetive transaction periodically
    return true if time_difference < @time_limit
    return false 
  end

  # check of passing the daily limit per user 
  # expecting the transaction object passed in the request
  def daily_limit(transaction)
    # getting the records made by the user through the day
    daily_transactions = Transaction.where(user_id: transaction.user_id).where(transaction_date: Date.today.all_day)
    return false unless daily_transactions # in case of first transaction of the day

    # daily transaction limit
    @payment_limit = 5000

    # if the new transaction exceeds the limit of the daily limit it should raise the suspicion
    return true if transaction.transaction_amount > @payment_limit

    # Getting the total of the transaction made by thue user on that day
    daily_payment_made = daily_transactions.sum(:transaction_amount)

    

    # checking the rule of limited payment per day
    return true if daily_payment_made >= @payment_limit
    return false
  end

  # check of history of chargebacks
  #  expecting the transaction object passed in the request
  def cbk_history(transaction)
    # get the count of previous chargebacks made by the user
    chargebacks_history = Transaction.where(user_id: transaction.user_id ).where(has_cbk: true).count

    # checking the rule of previous chargebacks 
    return true if chargebacks_history > 0
    return false
  end

  # allowed params by the controller to the action
  def transaction_params
     params.permit(:transaction_id, :merchant_id, :user_id, :card_number, :transaction_amount, :device_id, :has_cbk)
  end
end
