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
    def where_handler(where)
        # pp where
        # p !where.empty?
        if !where.empty?
            # p "ran"
            if !where[:table].nil?
                table_prefix = where[:table].to_s + "."
            else
                table_prefix =""
            end
            # pp table_prefix
            where.delete(:table)
            condition = " WHERE "
            ands = where.length - 1
            where.each do |key, value|
                condition += table_prefix + key.to_s + " = " + value.to_s
                if ands > 0
                    condition += " AND "
                    ands -= 1
                end
            end
            # pp condition
            return condition
        end
    end
    
    def join_handler(join)
        # pp join
        # pp if !join.empty?
        if !join == ""
            joiner = ""
            join.each do |key, value|
                # pp key
                # pp value
                if !value[:type].nil?
                    type = value[:type].upcase+" "
                end
                joiner += " #{type}JOIN #{key.to_s} ON #{value[:condition].values.first}.#{value[:condition].keys.first} = #{value[:condition].values.last}.#{value[:condition].keys.last}"
            end
            
            return joiner
        end
    end
    
    def order_handler(order)
        if !order == ""
            order_str = " ORDER BY #{order[:table]}.#{order[:field]} #{order[:direction].upcase}"
        end
    end
    
    def limit_handler(limit)
        if !limit.empty?
            limit_str = " LIMIT #{limit}"
        end
    end
    
    def insert_handler(fields)
        # pp fields
        output_keys=''
        i=0
        fields.each do |key, _|
            # pp key.to_s
            if i > 0
                output_keys += ', '+'"'+ key.to_s+'"'
            else
                output_keys += '"'+key.to_s+'"'
            end
            i +=1
        end
        
        return output_keys
    end
    
    def values_handler(values)
        output_values=''
        i=0
        values.each do |_, value|
            if i > 0
                output_values += ', '+'"'+value.to_s+'"'
            else
                output_values += '"'+value.to_s+'"'
            end
            i +=1
        end
        return output_values
    end

    def update_handler(input)
        output = ""
        i=0
        input.each do |key, value|
            if i > 0
                output += ", "
            end
            output += key.to_s + " = " + '"' + value.to_s + '"'
            i+=1
        end
        return output
    end
    
    #   WORKS!
    #
    def fetch(fields:"*", where:, join:"", order:"", limit:"")
        # pp where*
        pp "SELECT #{fields.to_s.delete '[\"]'} FROM #{@table_name}#{join_handler(join)}#{where_handler(where)}#{order_handler(order)}#{limit_handler(limit)};"
        # pp @db.execute("SELECT #{fields.to_s.delete '[\"]'} FROM #{@table_name} #{join_handler(join)}#{where_handler(where)}#{order_handler(order)}#{limit_handler(limit)};")
    end
    
    #   WORKS!
    #
    def insert(fields:"") 
        @db.execute("INSERT INTO #{@table_name} (#{insert_handler(fields)}) VALUES (#{values_handler(fields)});")
    end
    
    #   IN PROGRESS!
    #
    def delete(where:"")
        @db.execute("DELETE FROM #{@table_name} #{where_handler(where)}")
    end
    
    def update(fields:"", where:"")
        # puts "UPDATE #{@table_name} SET #{update_handler(fields)}#{where_handler(where)};"
		@db.execute("UPDATE #{@table_name} SET #{update_handler(fields)}#{where_handler(where)};")
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

# u.fetch(fields:["usn", "content","refrence_id", "name"], join:{messages:{condition:{user_id:"messages", id:"users"}}, taggings:{type:"left", condition:{tag_id:"taggings", refrence_id:"messages"}}, tags:{type:"left", condition:{id:"tags", tag_id:"taggings"}}}, order:{field:"id", table:"messages", direction:"asc"})
# u.fetch(fields:["usn", "content", "refrence_id", "name"], join:{users:{type:"left", condition:{user_id:"messages", id:"users"}}, taggings:{type:"left", condition:{message_id:"taggings", id:"messages"}}, tags:{type:"left", condition:{id:"tags", tag_id:"taggings"}}})
# u.insert(fields:{usn:"test", pwd:"$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O", privileges:0})
# u.delete(where:{id:5})
# u.fetch(where:{id:1})
u.update(fields:{usn:"linus", privileges:1}, where:{id:5})