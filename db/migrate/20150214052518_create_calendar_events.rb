class CreateCalendarEvents < ActiveRecord::Migration
  def change
    create_table :calendar_events do |t|
      t.string :link
      t.text :summary
      t.text :description
      t.string :location
      t.datetime :start
      t.datetime :end
      t.string :google_id
      t.json :raw

      t.timestamps null: false
    end
  end
end
