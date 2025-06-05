module Utils
    def self.newer?(file1, file2)
      return false unless File.exist?(file2)
      File.mtime(file1) > File.mtime(file2)
    end
end