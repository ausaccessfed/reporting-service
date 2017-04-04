# frozen_string_literal: true

class ChangeDatabaseCollationToBinary < ActiveRecord::Migration
  def change
    execute('ALTER DATABASE COLLATE = utf8_bin')
  end
end
