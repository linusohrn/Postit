require_relative "module/StringManipulation.rb"

require "sqlite3"
require "bcrypt"
require "byebug"
include StringManipulation

class Hash

  # Public: Keys as string made into strings as symbols.
  #
  def keys_to_symbol
    self.map { |key, value| [key.to_sym, value] }.to_h
  end
end

# Public: Used by all models in order to provide access to the database.
# All methods are inherited and used by the respective classes
#
#
# Examples
#
#   Users.fetch
#   # => [User_object, User_object]
#
#   Messages.delete
#   # => *POOF!*
#   
#   Taggings.add_child(Object)
#   # => <Taggings, childs=[Object]>
#
class Handler

  # ------------------------------- / setters
  def self.set_table_name(name)
    @table_name = name
  end

  def self.set_fields(name)
    @fields ||= []
    @fields << name
  end

  def self.set_unique(name)
    @unique ||= []
    @unique << name
  end

  def self.set_children(name)
    @children ||= []
    @children << name
    # byebug
  end
  # ------------------------------- / Setters

  # ------------------------------- / Getters
  def children
    @childs ||= []
    @children
  end

  def self.children
    @childs ||= []
    @children
  end

  def childs
    @childs ||= []
    @childs
  end

  def self.childs
    @childs ||= []
    @childs
  end

  def self.table_name
    @table_name
  end

  def self.fields
    @fields
  end

  def self.unique
    @unique
  end

  # ------------------------------- / Getters

  # ------------------------------- / Adders
  def add_child(obj)
    @childs ||= []
    if obj.class == Array
      obj.each do |ob|
        @childs << ob
      end
    else
      @childs << obj
    end
  end

  # ------------------------------- / Adders

  # public: Creates new object and sets necessary attributes.
  #
  #
  # contruction - true or false, if the given object is constructed from database there is no need to save it to database immediately
  # args - hash of the given attributes and values
  #
  # Returns created object.
  #
  def initialize(construction, **args)
    @db ||= SQLite3::Database.new("db/db.db")
    @db.results_as_hash = true
    @table_name = self.class.table_name
    @unique = self.class.unique
    @fields = self.class.fields
    @children = self.class.children
    @childs = self.childs
    args.each do |key, value|
      self.instance_variable_set("@#{key}", value)
    end

    if !construction
      self.save
    end
  end

  # Internal: Turns the data given from database into object of correct class.
  #
  # result_hash - The hash given by the databse
  #
  #
  # Examples
  #
  #   construct_object(id=>1,usn=>"admin", pwd=>"$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O", privilieges=>1)
  #   # => #<Users:0x0000000004fba640, @children="Messages", @childs=[], @db=sqlite3::database, @unique=["id", "usn"], @fields=["id", "usn", "pwd", "privilgeges"]@id=1, @usn="admin", @pwd="$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O", @privileges=1, >
  #
  # Returns the new object
  def self.construct_object(result_hash)
    if !result_hash.nil? && !result_hash.empty?
      class_hash = Hash.new
      result_hash = result_hash.to_h.keys_to_symbol
      result_hash.each do |class_key, attribute_val|
        class_name = class_key.to_s.rpartition(".")[0]
        class_attribute = class_key.to_s.rpartition(".")[2]
        class_hash[:"#{class_name}"] ||= Hash.new
        class_hash[:"#{class_name}"][:"#{class_attribute}"] = attribute_val
      end

      obj_arr ||= []
      class_hash.each do |klass, attr_hash|
        klass = klass.to_s.capitalize()
        obj_arr << Kernel.const_get(klass).new(true, attr_hash)
      end

      obj_arr.each_with_index do |obj, index|
        if !obj.children.nil? && !obj.children.empty?
          obj.children.each do |child|
            if !obj_arr[index + 1].nil?
              if child == obj_arr[index + 1].class.to_s
                obj.add_child(obj_arr[index + 1])
              end
            end
          end
        end
      end

      return obj_arr
    end
  end

  # Public: Fetches chosen data from database.
  #
  # fields - array of cells to be chosen
  # where - hash containing condition for rows to be selected
  # join - hash with containing table name and condition for a sql join
  # order - hash containing the order for the data given by database
  # limit - limit amount of rows given
  #
  # Examples
  #
  #   users.fetch(where:{id:1})
  #   # => {id=>1,usn=>"admin", pwd=>"$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O", privilieges=>1}
  #
  # Returns hash from database
  #
  def self.fetch(fields: "*", where: nil, join: nil, order: nil, limit: nil)
    @obj_arr = Array.new

    execute("SELECT #{fields_handler(fields)} FROM #{@table_name} AS '#{@table_name}'#{join_handler(join)}#{where_handler(where)}#{order_handler(order)}#{limit_handler(limit)};").each do |result_hash|

      #   WHAT THE ACTUAL FUCK IS HAPPENING
      result = construct_object(result_hash)

      while result.class == Array
        result = result.first
      end

      if !result.nil?
        @obj_arr << result
      end
    end

    return @obj_arr
  end

  # Public: Updates given attributes.
  #
  #
  # args - limitless hash for attributes and values
  #
  # Returns nothing
  #
  def update(**args)
    args.each do |key, value|
      if !@unique.include? key
        self.instance_variable_set("@#{key}", value)
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
    if !@fields.nil? && !@fields.empty?
      existing = exist_in_db?

      if !existing.nil?
        execute("UPDATE #{@table_name} SET #{update_handler(@fields)}#{where_handler(existing)};")
      else
        execute("INSERT INTO #{@table_name} (#{insert_handler(@fields)}) VALUES (#{values_handler(@fields)});")
      end
    else
      raise "please give your #{@table_name} some values"
    end
  end

  def exist_in_db?
    if !@unique.nil? && !@unique.empty?
      @unique.each do |uniq|
        if !self.public_send(uniq).nil?
          duplicate = execute("SELECT * FROM #{@table_name} WHERE #{uniq} = '#{self.public_send(uniq)}';")
        else
          return nil
          break
        end

        if !duplicate.empty?
          return duplicate.first
          break
        end
      end
    end
  end

  # Internal: Verify that database exists before executing sql.
  #
  #
  #   str - given sql string
  #
  # Returns nothing
  #
  def self.execute(str)
    @db ||= SQLite3::Database.new("db/db.db")
    @db.results_as_hash = true

    @db.execute(str)
  end

  def execute(str)
    @db ||= SQLite3::Database.new("db/db.db")
    @db.results_as_hash = true

    @db.execute(str)
  end

  # Public: Starts a database transaction and if a block is provided also commits.
  #
  # Returns nothing
  #
  def transaction
    @db ||= SQLite3::Database.new("db/db.db")
    @db.results_as_hash = true
    @db.transaction

    if block_given?
      yield
      @db.commit
    end
  end

  # Public: Commits current transaction.
  #
  # Returns nothing
  #
  def commit
    @db ||= SQLite3::Database.new("db/db.db")
    @db.results_as_hash = true
    @db.commit
  end

  def self.transaction
    transaction { yield }
  end

  def self.commit
    commit
  end

  # Public: Deletes current object from database.
  #
  # Returns nothing
  #
  def delete
    execute("DELETE FROM #{@table_name} WHERE id = #{@fields["id"]}")
  end

  # Public: Deletes chosen data from database.
  #
  # where - hash containing cell:value for the row to be deleted
  #
  # Return nothing
  #
  def self.delete(where:)
    execute("DELETE FROM #{@table_name} #{where_handler(where)}")
  end

end

Dir["model/*.rb"].each { |file| require_relative file }
