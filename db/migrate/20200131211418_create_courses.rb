class CreateCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :courses do |t|
      t.string :name
      t.text :description
      t.references :city, foreign_key: true
      t.datetime :start_course

      t.timestamps
    end
  end
end
