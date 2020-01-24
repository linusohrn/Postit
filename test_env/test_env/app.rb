require_relative('handler.rb')
require 'pp'
require 'byebug'
system('cls')
class App < Sinatra::Base
    
    enable :sessions
    
    def initialize
        Users.new
        Messages.new
        Taggings.new
        Tags.new
        @admin_id = "1" 
        super
    end
    
    before '/users*' do
        if !session[:user_id]
            redirect '/'
        end
    end
    
    before '/users/:user_id/wall' do
        # pp session[:user_id]
        # pp params[:user_id]
        if session[:user_id] != params[:user_id].to_i
            redirect "/users/#{session[:user_id]}/wall"
        end
    end
    
    get '/' do
        @failed ||= true
        @failed = session[:login]
        slim :index
    end
    
    get '/signup' do 
        slim :signup
    end
    
    get '/users/:user_id/wall?' do
        m_tag={}
        # pp params
        if params.key?(:reply_id) then @refrence_id = params[:reply_id] 
        end
        if params.key?(:tag_filter_id) then tag_filter_id = params[:tag_filter_id] 
        end
        if params.key?(:message_filter_id) then  message_filter_id = params[:message_filter_id] 
        end

        if params.key?(:tag_filter_id)
            filter_id = params[:tag_filter_id]
            type = "tag"
        elsif params.key?(:message_filter_id)
            filter_id = params[:message_filter_id]
            type = "message"
        end
        # pp filter_id

        if !filter_id.nil?
            @messages = Messages.get_all_message_and_usn_filter(filter_id, type)
            @messages = Messages.get(field:['message.id', 'message.content', 'message.refrence_id', 'users.usn'], join:['LEFT JOIN taggings ON message.id = taggings.message_id', 'INNER JOIN users ON message.user_id = user.id'])
        else
            @messages = Messages.get(join:['LEFT JOIN taggings ON message.id = taggings.message_id', 'INNER JOIN users ON message.user_id = user.id'])
        end
        tags = Tags.get_tags_name_and_message_id()
        
        @tags = Tags.get_all
        # pp @tags
        @user = params[:user_id]
        
        tags.each do |tag|
            if !m_tag[tag['id']].nil?
                m_tag[tag['id']] << tag['tagname']
            else
                m_tag[tag['id']] = [tag['tagname']]
            end
        end
        @messages.each do |message|
            message['tags'] = m_tag[message['id']]
        end
        
        @messages.uniq!
        # pp @messages
        slim :wall
    end
    
    
    get '/users/:user_id/profile?' do
        # pp params
        user = params['user_id'].to_i
        @user = Users.get_by_id(user, "*").first
        # pp @user
        slim :profile
    end
    
    post '/signup/create/?' do

        pwd_hash = BCrypt::Password.create(params[:password])
        Users.insert(fields:{usn:params[:username], pwd:pwd_hash})

        redirect '/'
    end
    
    post '/login/?' do 
        user_info = Users.get_by_usn(params[:username], 'id, pwd').first
        user_info = Users.fetch(fields:["id", "pwd"], where:{})
        if user_info.nil?
            session[:login] = false
            redirect '/'
        end
        # puts "here"
        pwd_hash = BCrypt::Password.new(user_info['pwd'])
        # p params[:password]
        # byebug
        if pwd_hash == params[:password]
            # pp true
            session[:user_id] = user_info['id']
            session[:login] = true
            redirect "/users/#{session[:user_id]}/wall"
        else
            # pp params
            # pp user_info
            # pp pass_hash
            # pp user_info['pwd']
            session[:login] = false
            redirect '/'
        end  
    end
    
    post '/users/:user_id/wall/new' do
        # pp params
        tag_arr = params['tag']
        # pp tag_arr
        Messages.create(params[:content], params[:user_id], tag_arr, params['refrence_id'])
        redirect "/users/#{params[:user_id]}/wall"
    end
    
    post '/users/:user_id/wall/:message_id/delete' do 
        Messages.delete_by_id(params[:message_id])
        Taggings.delete_by_m_id(params[:message_id])
        redirect "/users/#{params[:user_id]}/wall"
    end
    
    post '/users/:user_id/wall/:message_id/reply' do
        reply_id = params[:message_id]
        redirect "/users/#{params[:user_id]}/wall?reply_id=#{reply_id}"
    end
    
    post '/users/:user_id/wall/filter' do
        tag_filter_id = params[:filter]
        redirect "/users/#{params[:user_id]}/wall?tag_filter_id=#{tag_filter_id}"
    end
    
    post '/users/:user_id/profile/update_pwd' do 
        # pp params
        session[:counter] ||= 0
        if session[:counter] < 3
            pwd_hash = Users.get_by_id(params[:user_id], "pwd").first['pwd']
            # pp pwd_hash
            # pp params[:new_pwd]
            # pp params['new_pwd']
            if params['old_pwd'] == params['old_pwd_confirmed'] && params['new_pwd'] == params['new_pwd_confirmed'] && BCrypt::Password.new(pwd_hash) == params['old_pwd']
                pwd_hash = BCrypt::Password.create(params['new_pwd'])
                Users.update_pwd_by_id(params[:user_id], pwd_hash)
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
