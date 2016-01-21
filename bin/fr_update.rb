#!/usr/bin/env ruby

require_relative '../config/environment.rb'

UpdateFromFederationRegistry.new.perform if $PROGRAM_NAME == __FILE__
