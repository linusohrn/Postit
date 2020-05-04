class Tags < Handler
    attr_reader :id
    attr_accessor :name
    set_table_name "Tags"
    set_fields "id"
    set_fields "name"
    set_unique "id"
    set_unique "name"
    
    def initliaze(construction=false,**args)
        super(construction, args)
    end
    
end