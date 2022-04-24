require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'

get('/') do
    slim(:start)
end

get('/error') do 
    slim(:error)
end

get('/register') do 
    slim(:register)
    


end
get '/logout' do
    "Hello World"
    slim(:logout)
end

get('/admin') do
    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    slim(:admin)
end


post ('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true

    result = db.execute("SELECT userid FROM users WHERE username=?", username)

    if result.empty?
        if password == password_confirmation
            password_digest = BCrypt::Password.create(password)
            p password_digest
            db.execute("INSERT INTO users (username, password_digest) VALUES (?,?)", username, password_digest)
            redirect('/')
        else
            #kanske popup om orkar
            redirect('/error')
        end
    else
        redirect('/error')
    end
end


get '/showlogin' do

    username = params[:username]
    password = params[:password]

    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true

    result = db.execute("SELECT userid, password_digest FROM users WHERE username=?", username)

    if result.empty?
        # redirect('/error')
    end                 #FIXA NÄSTA GÅNG VETTE FAN
    
    p result
    if result.length != 0
        user_id = result.first["userid"]    
    end    
    password_digest = result.first["passowrd_digest"]
    if BCryt::Password.new(password_digest) == password
        session[:user_id] = user_id
        redirect('/lists')
    else
        set_error("Ivalid Credentials")
        redirect('/error')
    end
    slim(:showlogin)
end

get '/register_confirmation' do
    "du är inne"
    slim(:register_confirmation)
end

# def database_connect()
#     #skapa koppling till databas
#     db = SQLite3::Database.new("db/store.db")
#     #Få svar i strukturen [{},{},{}]
#     db.results_as_hash = true
#     #hämta data, skicka data
#     result = db.execute ("SELECT")
# end



# FIXA NÄSTA GÅNG HÄR !!!!!

##DENNA KODEN SKA VARA I LOGGIN FÖR ATT VALIDERA EN ANVÄNDARE

##DOKUMENTERA NÄSTA GÅNGq

get('/food') do
    
    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true
    food_items = db.execute("SELECT foodId, foodTitle, Votes FROM foodtable")
    
    
    p food_items

    slim(:food,locals:{foodvariable:food_items})
end
