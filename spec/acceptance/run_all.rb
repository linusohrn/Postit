# RUNS ALL ACCEPTANCE TESTS
system("ruby db/seeder.rb")
Dir['*_spec.rb'].each {|file| system("ruby #{file}")}
