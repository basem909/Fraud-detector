require 'rails_helper'

RSpec.describe "::Transactions", type: :request do
  describe "Post /transaction" do
    it "Sends a recommendation of aproval for the non-suspecious activity" do
      post '/transaction', params: {
        transaction_id: 123,
        merchant_id: 2314,
        user_id: 222,
        transaction_amount: 200,
        transaction_date: DateTime.now,
        device_id: 1999,
      }

      json = JSON.parse(response.body).deep_symbolize_keys

      expect(response).to have_http_status(200)
      expect(json[:recommendation]).to eq('Approve')
    end
  end
end
