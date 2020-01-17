require 'sqlite3'
require 'bcrypt'

class Handler
    
    def self.set_table_name(name)
        @table_name = name
    end
    
    def self.fields(name)
        @fields ||= []
        @fields << name
    end
    
    def self.connect()
        @db ||= SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true
        pp @table_name
        pp @fields
    end

    def self.create
        note = yield

        cells = ''
        note.keys.each_with_index {|key,index| index>0 ? cells +=  ', ' + key.to_s : cells += key.to_s}

        values = ''
        note.keys.each_with_index do |key, index|
            if !note[key].nil?
                index>0 ? values +=  ', ' + note[key].to_s : values += note[key].to_s
            else
                values += ", nil"
            end
        end
        # note.keys.each_with_index {|key,index| index>0 ? values += ', ' + note[key].to_s : values += note[key].to_s}
        pp "cells: " + cells
        pp "values: " + values
        @db.execute("INSERT INTO #{@table_name} (#{cells}) VALUES (#{values});")

    end

    def self.get_all
        @db.execute("SELECT * FROM #{@table_name}")
    end

    def self.get_cell_by(cell, field, value)
        @db.execute('SELECT ? FROM ? WHERE ? = ?', cell, @table_name, field, value)
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
    
end

class Taggings < Handler
    
    set_table_name "taggings"
    fields "message_id"
    fields "tag_id"
    
    def self.connect()
        super
    end
    
end

class Tags < Handler
    
    set_table_name "tags"
    fields "id"
    fields "name"
    
    def self.connect()
        super
    end
    
end
params = {content: "testing", user_id: 1, refrence_id: nil}
Messages.connect()
Messages.create {params}