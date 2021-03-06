class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :description
      t.references :project, index: true

      t.timestamps
    end
    add_index :tasks, :name
  end
end
