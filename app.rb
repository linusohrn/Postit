require_relative('handler_db.rb')
require 'pp'
system('cls')
class App < Sinatra::Base
    
    enable :sessions
    
    def initialize
        Users.connect
        Messages.connect
        Message_Tags.connect
        Tags.connect
        super
    end
    
    # before '/wall*' do
    #     if !session[:user_id]
    #         redirect '/'
    #     end
    # end
    
    get '/' do 
        @failed = session[:login]
        slim :index
        
    end
    
    get '/users/:user_id/wall' do 
        m_tag={}
        pp params[:user_id]
        @messages = Messages.get_all_message_and_usn
        tags = Tags.get_tags_name_and_message_id()
        # p tags
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
        @messages = @messages.uniq
        slim :wall
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
        pp params[:user_id]
        if params[:user_id] == 1
            Messages.create(params[:content], params[:user_id], [])
            
        end
        # pp params[:user_id]
        pp params
        redirect "/users/#{params[:user_id]}/wall"
    end
    
    
    
end
