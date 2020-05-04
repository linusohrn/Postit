class Messages < Handler
    attr_reader :id
    attr_accessor :content, :refrence_id, :user_id
    set_table_name "Messages"
    set_fields "id"
    set_fields "content"
    set_fields "refrence_id"
    set_fields "user_id"
    set_unique "id"
    set_children "Tags"
    
    def initialize(construction=false,**args)
        super(construction, args)
    end
    
end