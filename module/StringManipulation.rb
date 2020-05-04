# Public: Various methods to convert hashes into sql-appropriate strings.
#
#
#
#   Examples
#
#   where_handler({id:1})
#   # => "Where id = '1'""
#
#   order_handler({ table : "messages", field : "id", direction : "ASC" })
#   # => ORDER BY messages.id ASC
#
#
module StringManipulation

  # Public: Returns a string with the desired fields fit for sql request.
  #
  #   fields - Array of the desired fields to be retrieved from database
  #
  #   Examples
  #
  #   fields_handler(["id", "pwd"])
  #   # => id AS #{@table_name}.id, pwd AS #{@table_name}.pwd
  #
  def fields_handler(fields)
    out = ""
    i = 0
    if fields == "*"
      @fields.each do |field|
        if i == 0
          out += "#{field.to_s} AS '#{@table_name}.#{field.to_s}'"
        else
          out += ", #{field.to_s} AS '#{@table_name}.#{field.to_s}'"
        end
        i += 1
      end
    else
      fields.each do |field|
        if i == 0
          out += "#{field.to_s} AS '#{field.to_s}'"
        else
          out += ", #{field.to_s} AS '#{field.to_s}'"
        end
        i += 1
      end
    end
    return out
  end

  # Public: Takes nested hash and returns as string fit for where part of sql request.
  #
  #   where - Nested hash with the desired conditions for SQL request. The table which the condition will be applied on can also be specified.
  #
  #   where_handler(where:{id:1, name:"hej"})
  #   ==> "WHERE id = 1 AND name = hej"
  #
  #   where_handler(where:{id:1, name:"hej"}, "OR")
  #   ==> "WHERE id = 1 OR name = hej"
  #
  def where_handler(where, type = nil)
    if !where.nil? && !where.empty?
      if where.first.last == "NOT EMPTY"
        condition = " WHERE #{where.first.first} IS NOT NULL AND TRIM(#{where.first.first}, ' ') != ''"
        return condition
      end
      if !where[:table].nil?
        table_prefix = where[:table].to_s + "."
      else
        table_prefix = ""
      end
      where.delete(:table)
      condition = " WHERE "
      counter = where.length - 1
      where.each do |key, value|
        condition += table_prefix + key.to_s + " = "
        if value.class == String
          condition += "'" + value.to_s + "'"
        else
          condition += value.to_s
        end
        if !type.nil?
          if counter > 0
            condition += " #{type} "
            counter -= 1
          end
        else
          break
        end
      end

      return condition
    end
  end

  # Public: Takes nested hash and returns as string fit for join part of sql request.
  #
  #   join - Nested hash with the table name and condition for the desired join
  #
  #   join_handler(tags: { type: "left", condition: { taggings: "tag_id", tags: "id" } })
  #   # => "LEFT JOIN tags ON taggings.tag_id = tags.id"
  #
  def join_handler(join)
    if !join.nil? && !join.empty?
      joiner = ""

      join.each do |key, value|
        if !value[:type].nil?
          type = value[:type].upcase + " "
        end
        joiner += " #{type}JOIN #{key.to_s} ON #{value[:condition].keys.first}.#{value[:condition].values.first} = #{value[:condition].keys.last}.#{value[:condition].values.last}"
      end

      return joiner
    end
  end

  # Public: Takes nested hash and returns as string fit for order part of sql request.
  #
  #   order - Nested hash with the cell and direction for the desired ordering
  #
  #   order_handler(order: { table: "messages", field: "id", direction: "asc" })
  #   # => "ORDER BY messages.id ASC"
  #
  def order_handler(order)
    if !order.nil? && !order.nil?
      order_str = " ORDER BY #{order[:table]}.#{order[:field]} #{order[:direction].upcase}"
    end
  end

  # Public: Takes integer and returns as string fit for limit part of sql request.
  #
  #   limit - Integer for the amount of rows to be returned
  #
  #   limit_handler(2)
  #   # => "LIMIT 2"
  #
  def limit_handler(limit)
    if !limit.nil? && !limit.empty?
      limit_str = " LIMIT #{limit}"
    end
  end

  # Public: Takes array and returns as string fit for insert part of sql request.
  #
  #   fields - Array with the cells to be retrieved from database
  #
  #   insert_handler(["id", "usn", "pwd"])
  #   # => "id, usn, pwd"
  #
  def insert_handler(fields)
    if !fields.nil? && !fields.empty?
      output_keys = ""
      i = 0
      fields.each do |cell|
        if !cell.nil? && cell != "id"
          if i > 0
            output_keys += ", " + '"' + cell + '"'
          else
            output_keys += '"' + cell + '"'
          end
          i += 1
        end
      end

      return output_keys
    end
  end

  # Public: Takes array and returns as string fit for values part of sql request.
  #
  #   fields - Array with the cell and direction for the desired ordering
  #
  #   values_handler(["id", "usn", "pwd"])
  #   # => "1, admin, $2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O"
  #
  def values_handler(fields)
    if !fields.nil? && !fields.empty?
      output_values = ""
      i = 0
      fields.each do |cell|
        if !cell.nil? && cell != "id"
          if i > 0
            output_values += ", " + '"' + self.public_send(cell).to_s + '"'
          else
            output_values += '"' + self.public_send(cell).to_s + '"'
          end
          i += 1
        end
      end
      return output_values
    end
  end

  # Public: Takes nested array and returns as string fit for update part of sql request.
  #
  #   input - Array with the cells to be changed in database
  #
  #   update_handler(["id", "usn", "pwd"])
  #   # => "id = 1, usn = admin, pwd = $2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O"
  #
  def update_handler(input)
    if !input.nil? && !input.empty?
      output = ""
      i = 0

      input.each do |cell|
        if !@unique.include? cell
          if !self.public_send(cell).to_s.nil? && !self.public_send(cell).to_s.empty?
            if i > 0
              output += ", "
            end
            output += cell.to_s + " = " + '"' + self.public_send(cell).to_s + '"'
            i += 1
          end
        end
      end
      return output
    end
  end
end
