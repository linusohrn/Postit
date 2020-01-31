require 'sqlite3'
require 'bcrypt'
require 'byebug'

class Hash
    def keys_to_symbol
        self.map{|key, value| [key.to_sym, value]}.to_h
    end
end

class Handler
    
    def self.set_table_name(name)
        @table_name = name
    end
    
    def self.set_fields(name)
        @fields ||= {}
        @fields[name] = nil
    end
    
    def self.table_name
        @table_name
    end
    
    def self.fields
        @fields
    end
    
    def initialize(**args)
        @table_name = self.class.table_name
        @fields ||= {}
        args.each do |key, value|
            # p "#########################"
            # p key.to_s
            # p value
            @fields[key.to_s] = value
        end
        # pp @fields
    end
    
    
    
    #   TAKES NESTED ARRAY AND RETURNS AS STRING FIT FOR SQL REQUEST
    # 
    #   where - Nested array with the desired conditions for SQL request. The table which the condition will be applied on can also be specified.
    #
    #   where_handler(where:{id:1, name:"hej"})
    #   ==> "WHERE id = 1 AND name = hej" 
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
            where.delete(:table)
            condition = " WHERE "
            ands = where.length - 1
            where.each do |key, value|
                condition += table_prefix + key.to_s + " = " + "'"+value.to_s+"'"
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
        fields.each do |key, value|
            if !value.nil?
                # pp key.to_s
                if i > 0
                    output_keys += ', '+'"'+ key.to_s+'"'
                else
                    output_keys += '"'+key.to_s+'"'
                end
                i +=1
            end
        end
        
        return output_keys
    end
    
    def values_handler(values)
        output_values=''
        i=0
        values.each do |_, value|
            if !value.nil?
                if i > 0
                    output_values += ', '+'"'+value.to_s+'"'
                else
                    output_values += '"'+value.to_s+'"'
                end
                i +=1
            end
        end
        return output_values
    end
    
    def update_handler(input)
        output = ""
        i=0
        # pp input
        input.each do |key, value|
            # pp value
            if !value.nil?
                if i > 0
                    output += ", "
                end
                # pp key
                if key.to_s != "id"
                    output += key.to_s + " = " + '"' + value.to_s + '"'
                    i+=1
                end
            end
        end
        return output
    end
    
    def construct_object(result_hash)
        # pp result_hash
        result_hash = result_hash.to_h.keys_to_symbol
        # pp new(result_hash)
        return self.new(result_hash)
    end
    
    #   WORKS!
    #
    #
    def self.fetch(fields:"*", where:"", join:"", order:"", limit:"")
        connect()
        @obj_arr = Array.new
        # p @obj_arr
        execute("SELECT #{fields.to_s.delete '[\"]'} FROM #{@table_name} #{join_handler(join)}#{where_handler(where)}#{order_handler(order)}#{limit_handler(limit)};").each do |result_hash|
            
            #   WHAT THE ACTUAL FUCK IS HAPPENING 
            result = construct_object(result_hash)
            @obj_arr << result
            
        end
        # pp @obj_arr
        return @obj_arr
        
        #execute("SELECT #{fields.to_s.delete '[\"]'} FROM #{@table_name}#{join_handler(join)}#{where_handler(where)}#{order_handler(order)}#{limit_handler(limit)};").each do |result_hash|
        #     construct_object(result_hash)
        # end
    end
    
    #   WORKS!
    #
    #
    #   Check if id exists before saving
    #   if exists then UPDATE
    #   otherwise INSERT
    def save
        # pp @fields['id']
        if !@fields.nil? && !@fields.empty?
            # p "SELECT * FROM #{@table_name}#{where_handler(@fields)};"
            # pp !execute("SELECT * FROM #{@table_name}#{where_handler(@fields)};").first.nil?
            @fields.each do |key, value|
                pp key
                pp value
            end
            existing = execute("SELECT * FROM #{@table_name}#{where_handler(@fields)};").first
            # pp existing
            if !exist_in_db?(@fields)
                puts "UPDATE #{@table_name} SET #{update_handler(@fields)} WHERE id = #{existing['id']};"
                # execute("UPDATE #{@table_name} SET #{update_handler(@fields)} WHERE id = #{existing['id']};")
            else
                puts "INSERT INTO #{@table_name} (#{insert_handler(@fields)}) VALUES (#{values_handler(@fields)});"
                # execute("INSERT INTO #{@table_name} (#{insert_handler(@fields)}) VALUES (#{values_handler(@fields)});")
            end
        else
            puts "please give your #{@table_name} some values"
        end
    end

    def exist_in_db?(fields)
    
    def execute(str)
        db ||= SQLite3::Database.new('db/db.db')
        db.results_as_hash = true
        # p str
        db.execute(str)
    end
    
    
    #   WORKS!
    #
    def delete
        execute("DELETE FROM #{@table_name} WHERE id = #{@fields['id']}")
    end
    
    def self.delete(where:)
        execute("DELETE FROM #{@table_name} #{where_handler(where)}")
    end
    
    def self.transaction
        transaction
    end
    
    def self.commit
        commit
    end
    
    def data?
        @fields
    end
    
end

class Users < Handler
    
    set_table_name "users"
    set_fields "id"
    set_fields "usn"
    set_fields "pwd"
    set_fields "privileges"
    
    def initialize(**args)
        super(args)
    end
    
end

class Messages < Handler
    
    set_table_name "messages"
    set_fields "id"
    set_fields "content"
    set_fields "refrence_id"
    set_fields "user_id"
    
    def initialize(**args)
        super(args)
    end
    
end

class Taggings < Handler
    
    set_table_name "taggings"
    set_fields "message_id"
    set_fields "tag_id"
    
    def initialize(**args)
        super(args)
    end
    
end

class Tags < Handler
    
    set_table_name "tags"
    set_fields "id"
    set_fields "name"
    
    def initliaze(**args)
        super(args)
    end
    
end




# t = Users.new(usn:"trash", pwd:"$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O")
t = Users.new(usn:"wadda", privileges:1)
t.save
# p Users.new('id':1)
# p Users.new("id":1, "usn":"admin", "pwd":"$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O", "privileges":1)
# p z.data?
# Users.save
# Users.fetch(fields:["usn", "content","refrence_id", "name"], join:{messages:{condition:{user_id:"messages", id:"users"}}, taggings:{type:"left", condition:{tag_id:"taggings", refrence_id:"messages"}}, tags:{type:"left", condition:{id:"tags", tag_id:"taggings"}}}, order:{field:"id", table:"messages", direction:"asc"})
# u.fetch(fields:["usn", "content", "refrence_id", "name"], join:{users:{type:"left", condition:{user_id:"messages", id:"users"}}, taggings:{type:"left", condition:{message_id:"taggings", id:"messages"}}, tags:{type:"left", condition:{id:"tags", tag_id:"taggings"}}})
# u.insert(fields:{usn:"test", pwd:"$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O", privileges:0})
# u.delete(where:{id:5})
# u.fetch(where:{id:1})
# u.update(fields:{usn:"linus", privileges:1}, where:{id:5})
# Users.fetch(fields:["usn", "pwd"])