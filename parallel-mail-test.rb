#! /usr/bin/env ruby

require 'rubygems'
require 'faker'

def generate_test_list
  File.open('test-list.csv', 'w') do |f|
    1.upto(200000) { |i| f.write "#{i},#{Faker::Internet.email},#{Faker::Name.name}\n"}
  end
end