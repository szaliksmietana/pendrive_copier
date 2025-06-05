require_relative 'lib/validator'
require_relative 'lib/copier'

include Validator

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

Copier.copy_missing_and_newer(source, dest)