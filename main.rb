
require "optparse"
require "io/console"

require_relative "lib/scanner"
require_relative "lib/encryptor"
require_relative 'lib/validator'
require_relative 'lib/copier'

include Validator

options = {encrypt: false}
OptionParser.new do |opts|
    opts.banner = "Usage: ruby main.rb [options]"
    opts.on('-e', '--encrypt', 'Encrypt backup after copying') { options[:encrypt] = true}
    opts.on('-h', '--help', 'Show this help') do
      puts opts
      exit
    end
end.parse!

puts "USB File Copier"
puts "Enter path to the pendrive(source)
\nEXAMPLES
\nFor Linux/macOS: /path/to/pendrive
\nFor Windows: E:/path
\nEnter:"
source = gets.strip

puts "Enter path to the destination folder:"
dest = gets.strip

unless Validator.valid_directory?(source) && Validator.valid_directory?(dest)
    puts "Given path doesn't exist"
    exit 1
end

suspicious = Scanner.scan_quick(source)
if suspicious.any?
  puts "\nSuspicious files detected:"
  suspicious.each { |p| puts " - #{p}"}
  print "Continue copying? (y/n):"
  answer = gets.strip.downcase
  unless answer == 'y' || answer == 'yes'
    puts "Aborted by user"
    exit 0
  end
end

Copier.copy_missing_and_newer(source, dest)

if options[:encrypt]
  puts "\nEncryption requested. Creating archive..."
  print "Enter encryption password: "
  pw = STDIN.noecho(&:gets).strip
  puts ""
  print "Confirm password: "
  puts ""
  if pw.empty? || pw != pw2
    puts "Password do not match or empty. Aborting encryption"
    exit 1
  end

  out_file = Encryptor.create_encrypted_zip(dest, pw)
  if out_file
    puts "Encrypted achrive created: #{out_file}"
  else
    puts "Encryption failed."
  end
end

puts "Done."