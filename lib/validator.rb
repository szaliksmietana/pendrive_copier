module Validator
    def self.valid_directory?(path)
            Dir.exist?(path)
    end
end