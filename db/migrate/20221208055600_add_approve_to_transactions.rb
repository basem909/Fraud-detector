class AddApproveToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :approve, :boolean
  end
end
