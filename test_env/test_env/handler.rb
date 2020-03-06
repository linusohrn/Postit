require_relative 'modules/StringManipulation.rb'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
include StringManipulation

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
        @fields ||= []
        @fields << name
        self.instance_variable_set("@#{name}", nil)
    end
    
    def self.set_unique(name)
        @unique ||= []
        @unique << name
    end
    
    def self.set_has(name)
        
    end
    
    def self.table_name
        @table_name
    end
    
    def fields
        @fields
    end
    
    # def self.fields
    #     @fields
    # end
    
    def self.unique
        @unique
    end
    
    def initialize(construction, **args)
        @table_name = self.class.table_name
        # @fields ||= {}
        @unique = self.class.unique
        args.each do |key, value|
            # @fields[key.to_s] = value
            self.instance_variable_set("@#{key}", value)
        end

        if !construction
            self.save
        end
    end
    
    def self.construct_object(result_hash)
        # pp result_hash
        if !result_hash.nil? && !result_hash.empty?
            result_hash = result_hash.to_h.keys_to_symbol
            # pp new(result_hash)
            return self.new(true,result_hash)
        end
    end

    
    #   WORKS!
    #
    #
    def self.fetch(fields:"*", where: nil, join: nil, order: nil, limit: nil)
        # connect()
        # pp self.methods
        @obj_arr = Array.new
        # p @obj_arr
        execute("SELECT #{fields_handler(fields)} FROM #{@table_name} AS #{@table_name} #{join_handler(join)}#{where_handler(where)}#{order_handler(order)}#{limit_handler(limit)};").each do |result_hash|
            
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
    
    def update(**args)
        args.each do |key, value|
            if !@unique.include? key
                @fields[key.to_s] = value
            end
        end
    end
    
    def self.update(**args)
        update(args)
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
            # pp existing
            existing = exist_in_db?
            # pp existing
            if !existing.nil?
                
                # puts "UPDATE #{@table_name} SET #{update_handler(@fields)}#{where_handler(existing)};"
                execute("UPDATE #{@table_name} SET #{update_handler(@fields)}#{where_handler(existing)};")
            else
                # puts "INSERT INTO #{@table_name} (#{insert_handler(@fields)}) VALUES (#{values_handler(@fields)});"
                execute("INSERT INTO #{@table_name} (#{insert_handler(@fields)}) VALUES (#{values_handler(@fields)});")
            end
        else
            raise "please give your #{@table_name} some values"
        end
    end
    
    def exist_in_db?
        # pp "ran"
        # pp @unique
        if !@unique.nil? && !@unique.empty?
            @unique.each do |uniq|
                # pp uniq
                # pp @fields[uniq]
                
                duplicate = execute("SELECT * FROM #{@table_name} WHERE #{uniq.to_s} = '#{@fields[uniq]}';")
                # pp duplicate
                # pp duplicate.first
                if !duplicate.empty?
                    # pp "ran"
                    return duplicate.first
                    break
                end
            end
        end
    end
    
    def self.execute(str)
        @db ||= SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true
        pp str
        @db.execute(str)
    end
    
    def execute(str)
        @db ||= SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true
        pp str
        @db.execute(str)
    end
    
    def transaction
        @db ||= SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true
        @db.transaction
        # byebug
        if block_given?
            yield
            @db.commit
        end
        # @db.commit
        # yield(self)
    end
    
    def commit
        @db ||= SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true
        @db.commit
        
    end
    
    def self.transaction
        transaction{yield}
    end
    
    def self.commit
        commit
    end
    
    
    #   WORKS!
    #
    def delete
        execute("DELETE FROM #{@table_name} WHERE id = #{@fields['id']}")
    end
    
    def self.delete(where:)
        execute("DELETE FROM #{@table_name} #{where_handler(where)}")
    end
    
    # Starts a database transaction and if a block is provided also commits.
    #
    #
    #
    #
    #
    def self.transaction
        @db ||= SQLite3::Database.new('db/db.db')
        @db.results_as_hash = true
        @db.transaction
        # byebug
        if block_given?
            yield
            @db.commit
        end
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
    set_unique "id"
    set_unique "usn"
    # set_has Messages
    
    def initialize(construction=false, **args)
        super(construction, args)
    end
    
end

class Messages < Handler
    include StringManipulation
    set_table_name "messages"
    set_fields "id"
    set_fields "content"
    set_fields "refrence_id"
    set_fields "user_id"
    set_unique "id"
    # set_has Taggings
    
    def initialize(construction=false,**args)
        super(construction, args)
    end
    
end

class Taggings < Handler
    
    set_table_name "taggings"
    set_fields "message_id"
    set_fields "tag_id"
    # set_has Tags
    
    def initialize(construction=false,**args)
        super(construction, args)
    end
    
end

class Tags < Handler
    
    set_table_name "tags"
    set_fields "id"
    set_fields "name"
    set_unique "id"
    set_unique "name"
    
    def initliaze(construction=false,**args)
        super(construction, args)
    end
    
end