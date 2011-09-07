class DeleteSimulationTable < ActiveRecord::Migration
  def self.up
    drop_table :simulations
  end

  def self.down
    create_table :simulations do |t|
	t.integer :pid
    	t.string :username
      	t.string :filename
	t.string :output
	t.boolean :running
	t.timestamps
    end
  end
end
