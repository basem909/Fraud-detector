require 'rails_helper'

RSpec.describe "::Transactions", type: :request do

  before do
    time_limit_test = Transaction.create!( transaction_id: 1234,
        merchant_id: 2314,
        user_id: 222,
        transaction_amount: 51,
        transaction_date: DateTime.now,
        device_id: 1999,
        card_number: 12345678900000)

    chargeback_history_test = Transaction.create!( transaction_id: 12367,
        merchant_id: 5674,
        user_id: 86594,
        transaction_amount: 51,
        transaction_date: DateTime.now,
        device_id: 1999,
        card_number: 12345678900000,
        has_cbk: true)    
  end
  describe "Post /transaction" do
    it "Sends a recommendation of aproval for the non-suspecious activity" do
      post '/transaction', params: {
        transaction_id: 123,
        merchant_id: 2314,
        user_id: 225,
        transaction_amount: 200,
        transaction_date: DateTime.now,
        device_id: 1999,
      }

      json = JSON.parse(response.body).deep_symbolize_keys

      expect(response).to have_http_status(200)
      expect(json[:recommendation]).to eq('Approve')
    end

    it "Sends a recommendation of rejection for many transactions in a row" do
      
      post '/transaction', params: {
        transaction_id: 1234,
        merchant_id: 2314,
        user_id: 222,
        transaction_amount: 51,
        transaction_date: DateTime.now,
        device_id: 1999,
      }

      json = JSON.parse(response.body).deep_symbolize_keys

      expect(response).to have_http_status(200)
      expect(json[:recommendation]).to eq('Reject')
      expect(json[:transaction_id]).to eq(1234)
    end

    it "Sends a recommendation of rejection for exceeding the daily limit" do
      
      post '/transaction', params: {
        transaction_id: 1234,
        merchant_id: 2314,
        user_id: 2234,
        transaction_amount: 5100,
        transaction_date: DateTime.now,
        device_id: 1999,
      }

      json = JSON.parse(response.body).deep_symbolize_keys

      expect(response).to have_http_status(200)
      expect(json[:recommendation]).to eq('Reject')
      expect(json[:transaction_id]).to eq(1234)
    end

    it "Sends a recommendation of rejection for having a history of chargebacks" do
      # wait for 2 mins to avoid the time limit restriction
      sleep(2.minutes)
      post '/transaction', params: {
        transaction_id: 1234987,
        merchant_id: 5674,
        user_id: 86594,
        transaction_amount: 51,
        transaction_date: DateTime.now,
        device_id: 1999,
        card_number: 12345678900000,
      }

      json = JSON.parse(response.body).deep_symbolize_keys

      expect(response).to have_http_status(200)
      expect(json[:recommendation]).to eq('Reject')
      expect(json[:transaction_id]).to eq(1234987)
    end

  end
end
