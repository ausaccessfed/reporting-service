#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment.rb'

UpdateFromRapidConnect.new.perform if $PROGRAM_NAME == __FILE__
