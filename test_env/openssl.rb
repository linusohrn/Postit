require 'openssl'

key = OpenSSL::PKey::RSA.new 4096

open 'keys/private_key.pem', 'w' do |io| io.write key.to_pem end
open 'keys/public_key.pem', 'w' do |io| io.write key.public_key.to_pem end

encrypted = key.public_encrypt "test"
pp encrypted
decrypted = key.private_decrypt encrypted
pp decrypted
