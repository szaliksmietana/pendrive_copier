require 'zip'
require 'openssl'
require 'tmpdir'
require 'pathname'

require_relative 'validator.rb'

module Encryptor
  module_function

  def create_encrypted_zip(src_dir, password)
    unless valid_directory(src_dir)
      puts "Source directory not found: #{src_dir}"
      return nil
    end

    base = File.basename(src_dir.rstrip.gsub(/[\/\\]$/, ''))
    tmp_zip = File.join(Dir.tmpdir, "#{base}.zip")

    begin
      create_zip_from_directory(tmp_zip, src_dir)

      encrypted_out = File.join(File.dirname(src_dir), "#{base}.zip.enc")
      encrypt_file(tmp_zip, encrypted_out, password)

      File.delete(tmp_zip) if File.exist?(tmp_zip)
      encrypted_out
    rescue => e
      STDERR.puts "encryption error: #{e.message}"
      nil
    end
  end

  def create_zip_from_directory(zip_path, dir)
    ::Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
      Dir[File.join(dir, '**', '**')].each do |file|
        next if File.directory?(file)
          rel = Pathname.new(file).relative_path_from(Pathname.new(dir)).to_s

          rel = rel.gsub('\\', '/')
          zipfile.add(rel, file)
      end
    end
  end

  def encrypt_file(in_path, out_path, password)
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    salt = OpenSLL:Random.random_bytes(8)
    key_iv = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 20_000, cipher.key_len + cipher.iv_len, 'sha256')
    key = key_iv[0, cipher.key_len]
    iv = key_iv[cipher.key_len, cipher.iv_len]
    cipher.key = key
    cipher.iv = iv

    File.open(in_path, 'rb') do |fin|
      File.open(out_path, 'wb') do |fout|
        fout.write "salted__" + salt
        buf = ''
        while fin.read(4096, buf)
          fout.write cipher.update(buf)
        end
        fout.write cipher.final
  
      end
    end
  end
end