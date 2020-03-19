module StringManipulation
    
    
    def fields_handler(fields)
        # p "RAN"
        # pp fields
        # pp fields.first
        out = ""
        i = 0
        fields.each do |field|
            # pp field
            if i == 0
                out += "#{field.to_s} AS '#{field.to_s}'"
            else
                out += ", #{field.to_s} AS '#{field.to_s}'"
            end
            i+= 1
        end
        return out
        
    end
    
    #   TAKES NESTED ARRAY AND RETURNS AS STRING FIT FOR SQL REQUEST
    # 
    #   where - Nested array with the desired conditions for SQL request. The table which the condition will be applied on can also be specified.
    #
    #   where_handler(where:{id:1, name:"hej"})
    #   ==> "WHERE id = 1 AND name = hej" 
    def where_handler(where, type=nil)
        # pp where
        # p !where.empty?
        if !where.nil? && !where.empty?
            if !where[:table].nil?
                table_prefix = where[:table].to_s + "."
            else
                table_prefix =""
            end
            where.delete(:table)
            condition = " WHERE "
            counter = where.length - 1
            where.each do |key, value|
                condition += table_prefix + key.to_s + " = "
                if value.class == String
                    condition += "'"+value.to_s+"'"
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
            
            # pp condition
            return condition
        end
    end
    
    def join_handler(join)
        # pp join
        # pp if !join.empty?
        if !join.nil? && !join.empty? 
            joiner = ""
            pp join
            join.each do |key, value|
                # pp value
                if !value[:type].nil?
                    type = value[:type].upcase+" "
                end
                joiner += " #{type}JOIN #{key.to_s} ON #{value[:condition].keys.first}.#{value[:condition].values.first} = #{value[:condition].keys.last}.#{value[:condition].values.last}"
            end
            
            return joiner
        end
    end
    
    def order_handler(order)
        if !order.nil? && !order.nil?
            order_str = " ORDER BY #{order[:table]}.#{order[:field]} #{order[:direction].upcase}"
        end
    end
    
    def limit_handler(limit)
        if !limit.nil? && !limit.empty?
            limit_str = " LIMIT #{limit}"
        end
    end
    
    def insert_handler(fields)
        # pp fields
        if !fields.nil? && !fields.empty?
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
    end
    
    def values_handler(values)
        if !values.nil? && !values.empty?
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
    end
    
    def update_handler(input)
        if !input.nil? && !input.empty?
            output = ""
            i=0
            # pp input
            input.each do |key, value|
                # pp value
                
                # pp @unique
                if !value.nil?
                    if key.to_s != "id"
                        if i > 0
                            output += ", "
                        end
                        output += key.to_s + " = " + '"' + value.to_s + '"'
                        i+=1
                    end
                end
            end
            return output
        end
    end
    
end