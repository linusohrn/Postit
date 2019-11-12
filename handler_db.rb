require 'sqlite3'
require 'bcrypt'
require 'byebug'
class Handler_db 

    def self.connect
        @db = SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true
        user_by_usn("admin")
        user_by_id(1)
        user_by_privilege("admin")
    end

    def self.add_user(id, usn, pwd)
        pwd_hash = BCrypt::Password.create(pwd)
        @db.execute('INSERT INTO users id, usn, pwd VALUES (?,?,?)', id, usn, pwd_hash)
    end

    def self.get_from_user_by(cell ,field, value)
        return @db.execute("SELECT #{cell} FROM users WHERE #{field} = #{value};")
    end

    def self.user_by_id(int)
        puts get_from_user_by('*','id',int)
    end

    def self.user_by_usn(name)
        puts get_from_user_by('*','usn', "\"" + name + "\"")
    end

    def self.user_by_privilege(role)
        if role == "admin"
            role = 1
        elsif role == "pleb"
            role = 0
        end
        puts get_from_user_by('*','privileges',role)

    end

end

def Handler_table



end

Handler_db.connect