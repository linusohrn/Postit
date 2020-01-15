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
    
    def initialize
        @db ||= SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true
        pp @table_name
        pp @fields
        # get(field:['message.id', 'message.content', 'message.refrence_id', 'users.usn'], join:['LEFT JOIN taggings ON message.id = taggings.message_id', 'INNER JOIN users ON message.user_id = user.id'])
    end
    
    def self.get(field:"*", cell:"*", where:"", join:"", order_by:"", limit:"")
        fields_str = ""
        field.each do |str|
            fields_str += str
            if str != field[-1]
                fields_str += ", "
            end
        end

        pp fields_str
        pp join
        @db.execute("SELECT #{cell} FROM #{@table_name} #{where} #{join} #{order_by} #{limit}")
    end
    
    def self.insert(field:"*", value:"", where:"") 
        @db.execute("INSERT INTO #{@table_name} (#{field}) VALUES (?);", value)
    end
    
    def self.delete(field:"", where:"")
        @db.execute("DELETE FROM #{@table_name} #{where}")
    end
    
    def self.update(field:"", value:"", where:"")
        @db.execute("UPDATE #{@table_name} SET #{field} #{value} #{where}")
    end
    
end

class Users < Handler
    
    set_table_name "users"
    fields "id"
    fields "usn"
    fields "pwd"
    fields "privileges"
    
    def initialize
        super
    end
    
end

class Messages < Handler
    
    set_table_name "messages"
    fields "id"
    fields "content"
    fields "refrence_id"
    fields "user_id"
    
    def initialize
        super
    end
    
end

class Taggings < Handler
    
    set_table_name "taggings"
    fields "message_id"
    fields "tag_id"
    
    def initialize
        super
    end
    
end

class Tags < Handler
    
    set_table_name "tags"
    fields "id"
    fields "name"

    def initialize
        super
    end
    
end

Tags.new
