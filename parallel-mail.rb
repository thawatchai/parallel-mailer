#! /usr/bin/env ruby

WORKER_NUM = 10

require 'rubygems'
require 'ValidateEmail'
require 'pony'
require 'parallel'
require 'benchmark'

# Check ARGV
# -----------------------------------------------
if ARGV.count < 3
  puts "parallel-mail.rb email_list.csv from_address mail.txt"
  Process.exit
end

# Get email subject & body
# -----------------------------------------------
subject = nil
body = ''
File.open(ARGV[2]).each_line do |s|
  if subject.nil?
    subject = s.strip
  else
    body += s
  end
end

# Send the email in parallel
# -----------------------------------------------
# Benchmark.bm do |x|
#   x.report('test') do

    Parallel.each_with_index(File.open(ARGV[0], 'r'), :in_processes => WORKER_NUM) do |s, i|
      l = s.split(',')
      email = l[1].strip

      Pony.mail(
        :charset => 'utf-8',
        :text_part_charset => 'utf-8',
        :to => email,
        :from => ARGV[1],
        :subject => subject,
        :body => body
      ) if ValidateEmail.validate(email)

      puts"#{i} #{Process.pid} #{email}\n"
    end

#   end
# end
