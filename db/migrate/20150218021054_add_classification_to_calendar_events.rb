class AddClassificationToCalendarEvents < ActiveRecord::Migration
  def change
    add_column :calendar_events, :classification, :string
  end
end
