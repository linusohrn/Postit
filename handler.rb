require 'sqlite3'
require 'bcrypt'

class Handler
    
    def self.set_table_name(name)
        @table_name = name
    end

    def self.fields(name)
        @fields ||= []
        @fields << name
    
    def self.connect()
        @db ||= SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true
    end
    
end

class Users < Handler

    set_table_name "users"
    fields "id"
    fields "usn"
    fields "pwd"
    fields "privileges"
    
    def self.connect()
        super
    end

class Messages < Handler

    set_table_name "messages"
    fields "id"
    fields "content"
    fields "refrence_id"
    fields "user_id"
    
    def self.connect()
        super
    end