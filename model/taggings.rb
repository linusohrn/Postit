class Taggings < Handler
  attr_reader :message_id, :tag_id
  set_table_name "Taggings"
  set_fields "message_id"
  set_fields "tag_id"

  def initialize(construction = false, **args)
    super(construction, args)
  end
end
