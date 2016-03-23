#!/usr/bin/env ruby

require_relative '../config/environment.rb'

ProcessIncomingFTicksEvents.new.perform
