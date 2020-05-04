require_relative("handler.rb")
Dir["model/*"].each { |file| require_relative file }
require "pp"
require "byebug"
system("cls")

# Handles server routes.
class App < Sinatra::Base
  enable :sessions

  def initialize
    @admin_id = "1"
    super
  end

  # Checks that session has started before visitor visit anything except index and sign up page.
  before "/users*" do
    if !session[:user_id]
      redirect "/"
    end
  end

  # Checks that session id matches the user id.
  before "/users/:user_id/wall" do
    if session[:user_id] != params[:user_id].to_i
      redirect "/users/#{session[:user_id]}/wall"
    end
  end

  # Index page, wack timer function for wrong login info to throw off bad boys.
  get "/" do
    if session[:login].nil?
      session[:login] ||= true
    end
    session[:fails] ||= 0
    @failed = session[:login]
    if !session[:login]
      session[:fails] += 1
      sleep(Math::E ** session[:fails] * (Math.sin(session[:fails]) * Math.sin(session[:fails])))
    end
    slim :index
  end

  # Signup page
  get "/signup" do
    slim :signup
  end

  # Main posting wall, Able to filter posts based on tags and id.
  get "/users/:user_id/wall?" do
    m_tag = {}

    if params.key?(:reply_id) then @refrence_id = params[:reply_id] end
    if params.key?(:tag_filter_id) then tag_filter_id = params[:tag_filter_id] end
    if params.key?(:message_filter_id) then message_filter_id = params[:message_filter_id] end

    if params.key?(:tag_filter_id)
      filter_id = params[:tag_filter_id]
      type = "tags"
    elsif params.key?(:message_filter_id)
      filter_id = params[:message_filter_id]
      type = "messages"
    end

    if !filter_id.nil?
      if type == "messages"
        @all = Users.fetch(fields: ["users.usn", "messages.id", "messages.content", "messages.refrence_id", "tags.name"], join: { messages: { type: "Left", condition: { users: "id", messages: "user_id" } }, taggings: { type: "left", condition: { messages: "id", taggings: "message_id" } }, tags: { type: "left", condition: { taggings: "tag_id", tags: "id" } } }, where: { "messages.id": filter_id, "messages.refrence_id": filter_id }, order: { table: "messages", field: "id", direction: "asc" })
      elsif type == "tags"
        @all = Users.fetch(fields: ["users.usn", "messages.id", "messages.content", "messages.refrence_id", "tags.name"], join: { messages: { type: "Left", condition: { users: "id", messages: "user_id" } }, taggings: { type: "left", condition: { messages: "id", taggings: "message_id" } }, tags: { type: "left", condition: { taggings: "tag_id", tags: "id" } } }, where: { "tags.id": filter_id }, order: { table: "messages", field: "id", direction: "asc" })
      end
    else
      @all = Users.fetch(fields: ["users.usn", "messages.id", "messages.content", "messages.refrence_id", "tags.name"], join: { messages: { type: "Left", condition: { users: "id", messages: "user_id" } }, taggings: { type: "left", condition: { messages: "id", taggings: "message_id" } }, tags: { type: "left", condition: { taggings: "tag_id", tags: "id" } } }, where: { 'messages.content': "NOT EMPTY" }, order: { table: "messages", field: "id", direction: "asc" })
    end
    @tags = Tags.fetch

    @all.each do |user|
      @all.each do |usr|
        if user.usn == usr.usn
          message = user.childs.first
          msg = usr.childs.first
          if message.id == msg.id
            tag = message.childs.first
            tg = msg.childs.first
            if tag.name != tg.name
              message.add_child(tg)
              @all.delete(usr)
            end
          end
        end
      end
    end
    @all.uniq

    slim :wall
  end

  # Profile page.
  get "/users/:user_id/profile?" do
    @user = Users.fetch(where: { id: params["user_id"].to_i })

    slim :profile
  end

####################################################################################

  #Create user post. Immediately hashes plaintext password to avoid having plaintext.
  post "/signup/create/?" do
    pwd_hash = BCrypt::Password.create(params[:password])
    Users.new(usn: params[:username], pwd: pwd_hash)

    redirect "/"
  end

  # Fetches potential user and compares password hashes. If anything is wrong redirects to index and does session[:login] = false to have timer function working.
  post "/login/?" do
    user = Users.fetch(fields: ["users.id", "users.pwd"], where: { usn: (params[:username]) }).first

    if user.nil?
      session[:login] = false
      redirect "/"
    else
      @user = user.id
      pwd_hash = BCrypt::Password.new(user.pwd)

      if pwd_hash == params[:password]
        session[:user_id] = user.id
        session[:login] = true
        redirect "/users/#{session[:user_id]}/wall"
      else
        session[:login] = false
        redirect "/"
      end
    end
  end

  # Creates new message and 
  post "/users/:user_id/wall/new" do
    Handler.transaction()
    Messages.new(content: params[:content], user_id: params[:user_id], refrence_id: params["refrence_id"])
    if !params["tag"].nil? && !params["tag"].empty?
      
      m = Messages.fetch(where: { content: params[:content], user_id: params[:user_id], refrence_id: params["refrence_id"] }).first
      params["tag"].each do |tag_id|
        Taggings.new(message_id: m.id, tag_id: tag_id)
      end
    end
    Handler.commit()
    redirect "/users/#{params[:user_id]}/wall"
  end

  # Deletes wanted message and associated taggings
  post "/users/:user_id/wall/:message_id/delete" do
    Messages.delete(where: { id: params[:message_id] })

    Taggings.delete(where: { message_id: params[:message_id] })
    redirect "/users/#{params[:user_id]}/wall"
  end

  # Redirects to main wall with an id to use as refrence_id
  post "/users/:user_id/wall/:message_id/reply" do
    reply_id = params[:message_id]
    redirect "/users/#{params[:user_id]}/wall?reply_id=#{reply_id}"
  end

  # Redirects to main wall with filter to filter messages
  post "/users/:user_id/wall/filter" do
    tag_filter_id = params[:filter]
    redirect "/users/#{params[:user_id]}/wall?tag_filter_id=#{tag_filter_id}"
  end

  # Updates password for current user if all criteria is met. Also has a counted with hard stop at 3 to prevent bad boys.
  post "/users/:user_id/profile/update_pwd" do
    session[:counter] ||= 0
    if session[:counter] < 3
      user = Users.fetch(where: { id: params[:user_id] }).first
      pwd_hash = user.pwd

      if params["old_pwd"] == params["old_pwd_confirmed"] && params["new_pwd"] == params["new_pwd_confirmed"] && BCrypt::Password.new(pwd_hash) == params["old_pwd"]
        pwd_hash = BCrypt::Password.create(params["new_pwd"])
        user.pwd = pwd_hash
        user.save
        session[:counter] = 0
        @pwd_correct = true
        @updated = true
        @stopper = false
        redirect "/users/#{params[:user_id]}/profile"
      else
        @pwd_correct = false
        session[:counter] += 1
        redirect "/users/#{params[:user_id]}/profile"
      end
    else
      @stopper = true
      redirect "/users/#{params[:user_id]}/profile"
    end
  end
end
