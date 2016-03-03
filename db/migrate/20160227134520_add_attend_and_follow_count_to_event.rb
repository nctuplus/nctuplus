class AddAttendAndFollowCountToEvent < ActiveRecord::Migration
  def change
		add_column :events, :event_follows_count, :integer, :default => 0, :after=>:view_times
    add_column :events, :attendances_count, :integer, :default => 0, :after=>:view_times
    Event.pluck(:id).each do |i|
      Event.reset_counters(i, :attendances)
			Event.reset_counters(i, :event_follows)
    end
  end
end
