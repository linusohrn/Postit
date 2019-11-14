require 'sqlite3'
require 'bcrypt'
require 'byebug'
class Handler_db 

    def self.connect
        @db = SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true

        puts get_tag_from_message_by('(message.id, content, refrence_id, user_id, tag_name)', 'user_id', 1)
    end

    def self.user_add(usn, pwd, privileges=0)
        pwd_hash = BCrypt::Password.create(pwd)
        @db.execute('INSERT INTO users (usn, pwd, privileges) VALUES (?,?,?)', usn, pwd_hash, privileges)
    end

    def self.get_from_user_by(cell ,field, value)
        @db.execute("SELECT #{cell} FROM users WHERE #{field} = #{value};")
    end

    def self.user_by_id(int, cell)
        get_from_user_by(cell,'id',int)
    end

    def self.user_by_usn(name, cell)
        get_from_user_by(cell,'usn', "\"" + name + "\"")
    end

    def self.user_by_privilege(role,cell)
        if role == "admin"
            role = 1
        elsif role == "pleb"
            role = 0
        end
        get_from_user_by(cell,'privileges',role)

    end

    def self.message_add(content, refrence_id=nil, user_id)
        if !refrence_id.nil?
            @db.execute('INSERT INTO messages (content, refrence_id, user_id) VALUES (?,?,?)', content, refrence_id, user_id)
        else
            @db.execute('INSERT INTO messages (content, user_id) VALUES (?,?)', content, user_id)
        end
    end

    def self.get_from_message_by(cell ,field, value)
        @db.execute("SELECT #{cell} FROM messages WHERE #{field} = #{value};")
    end

    def self.message_by_id(int, cell)
        get_from_message_by(cell,'id',int)
    end

    def self.message_by_uid(int, cell)
        get_from_message_by(cell,'user_id',int)
    end

    def self.message_by_ref(ref, cell)
        message_with_ref=[]
        message_with_ref << message_by_id(ref, cell)
        message_with_ref << get_from_message_by(cell,'refrence_id',ref)
        return message_with_ref
    end

    def self.get_tag_from_message_by(cell, field, value)
        @db.execute("
            SELECT #{cell} FROM messages INNER JOIN message_tag ON messages.id = message_tag.message_id WHERE #{field} = #{value}
            ;")
    end




end

def Handler_table



end

Handler_db.connect