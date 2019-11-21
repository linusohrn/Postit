require_relative('handler_db.rb')
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

    get '/wall' do 
        
        @notes = Messages.get_all_message_tag_user
        # p @notes
        @notes.each do |note|
            # p note
            # p note['id']
            note['tags'] = Tags.get_tags_by_message_id(note['id']).to_a.first
            # p note['tags']
        end
        # @tags = Tags.get_tags_by_message_id
        # puts @tags
        # puts "#####################################"
        # p @notes
        # Messages.get_all_message_tag_user.each do |temp|
        #     p temp['name']
        # end
        # puts "#####################################"
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
            redirect '/wall'
        else
            session[:login] = false
            redirect '/'
        end
        
        
        
    end

    post '/new/?' do

        Messages.add(params[:content], session[:user_id])
        redirect '/wall'
    end
    
    
    
end
