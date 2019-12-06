require 'sqlite3'
require 'bcrypt'
# require 'byebug'
class Handler_db 
    
    def self.connect
        @db = SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true
        
    end
    
end

class Users < Handler_db
    
    def self.connect
        super
    end
    
    def self.add(usn, pwd, privileges=0)
        pwd_hash = BCrypt::Password.create(pwd)
        @db.execute('INSERT INTO users (usn, pwd, privileges) VALUES (?,?,?)', usn, pwd_hash, privileges)
    end
    
    def self.get_cells_by(cell ,field, value)
        @db.execute("SELECT #{cell} FROM users WHERE #{field} = #{value};")
    end
    
    def self.get_by_id(int, cell)
        get_cells_by(cell,'id',int)
    end
    
    def self.get_by_usn(name, cell)
        self.get_cells_by(cell,'usn', "\"" + name + "\"")
    end
    
    def self.get_by_privilege(role,cell)
        if role == "admin"
            role = 1
        elsif role == "pleb"
            role = 0
        end
        get_cells_by(cell,'privileges',role)
        
    end
    
end

class Messages < Handler_db
    
    def self.connect
        super
    end
    
    def self.create(content, user_id, tag_arr, refrence_id=nil)
        @db.transaction
        # pp refrence_id
        if !refrence_id.nil?
            @db.execute('INSERT INTO messages (content, refrence_id, user_id) VALUES (?,?,?)', content, refrence_id, user_id) 	
        else
            @db.execute('INSERT INTO messages (content, user_id) VALUES (?,?)', content, user_id)
        end
        last_m_id = @db.execute("SELECT id FROM messages ORDER BY id desc LIMIT 1").first['id']
        tag_arr.each do |tag|
            if !tag.nil?
                @db.execute("INSERT INTO taggings (message_id, tag_id) VALUES (?,?)", last_m_id, tag.to_i)
            end
        end
        @db.commit
    end

    def self.delete_by_id(id)
        @db.execute("DELETE FROM messages WHERE id = (?)", id)
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
    
    def self.get_all_message_and_usn
        
        @db.execute("SELECT m.id, m.content, m.refrence_id, u.usn FROM messages AS m LEFT JOIN taggings AS mt ON m.id = mt.message_id INNER JOIN users AS u ON m.user_id = u.id;")
    end

    def self.get_all_message_and_usn_filter()

    end
    
end



class Taggings < Handler_db
    
    def self.connect
        super
    end
    
    def self.add(message_id, tag_id)
        @db.execute("INSERT INTO taggings message_id, tag_id VALUES (?,?)", message_id, tag_id)
    end

    def self.delete_by_m_id(id)
        @db.execute("DELETE FROM taggings WHERE message_id = (?)", id)
    end
    
    
end


class Tags < Handler_db
    
    def self.connect
        super
    end
    
    def self.get_tags_name_and_message_id(message_id=nil)
        tag_names=[]
        
        if message_id.nil?
            tag_names << @db.execute("SELECT messages.id, tags.name as tagname
                FROM messages 
                JOIN taggings 
                ON taggings.message_id = messages.id
                JOIN users ON messages.user_id = users.id
                JOIN tags 
                ON taggings.tag_id = tags.id")
            else
                @db.results_as_hash = false
                tag_names << @db.execute("SELECT t.name FROM tags AS t INNER JOIN taggings AS mt ON t.id = mt.tag_id WHERE mt.message_id = #{message_id}")
                
            end
            return tag_names.first
        end
        
    end
    
    
    