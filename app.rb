require_relative('handler_db.rb')
require 'pp'
system('cls')
class App < Sinatra::Base
    
    enable :sessions
    
    def initialize
        Users.connect
        Messages.connect
        Taggings.connect
        Tags.connect
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
        else
            @messages = Messages.get_all_message_and_usn()
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
        pp params
        user = params['user_id'].to_i
        @user = Users.get_by_id(user, "*").first
        pp @user
        slim :profile
    end
    
    post '/signup/create/?' do
        
        pwd_hash = params[:password]
        Users.add(params[:username], pwd_hash)
        redirect '/'
    end
    
    post '/login/?' do 
        pwd_hash = Users.get_by_usn(params[:username], 'id, pwd').first
        if pwd_hash.nil?
            session[:login] = false
            redirect '/'
        end
        if BCrypt::Password.new(pwd_hash['pwd']) == params[:password]
            session[:user_id] = pwd_hash['id']
            session[:login] = true
            redirect "/users/#{session[:user_id]}/wall"
        else
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
end
