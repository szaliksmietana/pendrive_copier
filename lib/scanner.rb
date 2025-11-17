module Scanner
  SUSPICIOUS_EXT = %w[.exe .scr .bat .cmd .js .vbs .ps1 .com .cpl .msi .sh]
  SPECIAL_FILES = %w[autorun.inf]

  def self.scan_quick(root)
    results = []
    pattern = File.join(root, "**", "*")
    Dir.glob(pattern, File::Constants::FNM_CASEFOLD).each do |path|
      next unless File.file?(path)
        name = File.basename(path).downcase
        ext = File.extname(path).downcase
        if SPECIAL_FILES.include?(name)
          results << path
        elsif SUSPICIOUS_EXT.include?(ext)
          results << path
        end
        break if results.size >= 100
      end
      results
  end
end