class CreateSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :sessions do |t|
      t.references :course, foreign_key: true
      t.datetime :start_session
      t.integer :position_session

      t.timestamps
    end
  end
end
