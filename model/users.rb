class Users < Handler
  attr_reader :id
  attr_accessor :usn, :pwd, :privileges
  set_table_name "Users"
  set_fields "id"
  set_fields "usn"
  set_fields "pwd"
  set_fields "privileges"
  set_unique "id"
  set_unique "usn"
  set_children "Messages"

  def initialize(construction = false, **args)
    super(construction, args)
  end
end
