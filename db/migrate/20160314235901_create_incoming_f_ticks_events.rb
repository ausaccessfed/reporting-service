# frozen_string_literal: true

class CreateIncomingFTicksEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :incoming_f_ticks_events do |t|
      t.string :data, limit: 4096, null: false
      t.string :ip, null: false
      t.boolean :discarded, null: false, default: false, index: true

      t.timestamp :timestamp, null: false

      t.timestamps null: false
    end
  end
end
