require 'sqlite3'
require 'bcrypt'

class Handler

    def self.set_table_name(name)
        @table_name = name
    end
    
    def self.set_fields(name)
        @fields ||= []
        @fields << name
    end

    def self.table_name
        @table_name
    end

    def self.fields
        @fields
    end
    
    def initialize
        @db ||= SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true
        @table_name = self.class.table_name
        @fields = self.class.fields
    end

    #   WHERE_HANDLER
    #
    #   TAKES NESTED ARRAY AND RETURNS AS STRING FIT FOR SQL REQUEST
    # 
    #   where_handler(where:{id:1, name:"hej"})
    #   ==> WHERE id = 1 AND name = hej 
    def where_handler(where, table_prefix)
        table_prefix = where[:table].to_s
        where.delete(:table)
        condition = " WHERE "
        ands = where.length - 1
        where.each do |key, value|
            condition += table_prefix + "." + key.to_s + " = " + value.to_s
            if ands > 0
                condition += " AND "
                ands -= 1
            end
        end
        return condition
    end
    
    def join_handler(join)
        # pp join
        joiner = ""
        join.each do |key, value|
            # pp key
            # pp value
            if !value[:type].nil?
                type = " "+value[:type].upcase
            end
            joiner += "#{type} JOIN #{key.to_s} ON #{value[:condition].values.first}.#{value[:condition].keys.first} = #{value[:condition].values.last}.#{value[:condition].keys.last}"
        end
        
        return joiner
    end

    def order_handler(order)
        order_str = " ORDER BY #{order[:table]}.#{order[:field]} #{order[:direction].upcase}"
    end

    def limit_handler(limit)
        if !limit.empty?
        limit_str = " LIMIT #{limit}"
    end



    def fetch(fields:"*", where:"", join:"", order:"", limit:"")
        # pp order
        # pp @table_name
        pp "SELECT #{fields.to_s.delete! '[\"]'} FROM #{@table_name} #{join_handler(join)}#{where_handler(where,@table_name)}#{order_handler(order)}#{limit_handler(limit)};"
	    @db.execute("SELECT #{fields.to_s.delete! '[\"]'} FROM #{@table_name} #{join_handler(join)}#{where_handler(where,@table_name)}#{order_handler(order)}#{limit_handler(limit)};")
    end
   
    def insert(field:"*", value:"", where:"") 
	   @db.execute("INSERT INTO #{@table_name} (#{field}) VALUES (?);", value)
    end

    def delete(field:"", where:"")
	   @db.execute("DELETE FROM #{@table_name} #{where}")
    end

    def update(field:"", value:"", where:"")
		@db.execute("UPDATE #{@table_name} SET #{field} #{value} #{where}")
    end
    
end

class Users < Handler
    
    set_table_name "users"
    set_fields "id"
    set_fields "usn"
    set_fields "pwd"
    set_fields "privileges"
    
    def initialize
        super
    end
    
end

class Messages < Handler
    
    set_table_name "messages"
    set_fields "id"
    set_fields "content"
    set_fields "refrence_id"
    set_fields "user_id"
    
    def initialize
        super
    end
    
end

class Taggings < Handler
    
    set_table_name "taggings"
    set_fields "message_id"
    set_fields "tag_id"
    
    def initialize
        super
    end
    
end

class Tags < Handler
    
    set_table_name "tags"
    set_fields "id"
    set_fields "name"
    
    def initliaze
        super
    end
    
end

u = Users.new

u.fetch(fields:["usn", "pwd", "privileges", "content","refrence_id", "name"], where:{id:1, table:"users"}, join:{messages:{condition:{user_id:"messages", id:"users"}}, taggings:{type:"left", condition:{tag_id:"taggings", refrence_id:"messages"}}, tags:{type:"left", condition:{id:"tags", tag_id:"taggings"}}}, order:{field:"id", table:"messages", direction:"asc"})
