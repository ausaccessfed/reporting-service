# frozen_string_literal: true

class ChangeDatabaseCollationToBinary < ActiveRecord::Migration[4.2]
  def change
    execute('ALTER DATABASE COLLATE = utf8_bin')
  end
end
