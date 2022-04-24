require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
enable :sessions

get('/') do
    user_id = session[:user_id]
    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true

    usernamedisplay = db.execute("SELECT username FROM users WHERE userid = ?", user_id).first
    if usernamedisplay != nil
        usernamedisplay = usernamedisplay["username"]
    end

    slim(:start,locals:{usernamedisplay:usernamedisplay})
end

get('/error') do 

    user_id = session[:user_id]
    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true
    usernamedisplay = db.execute("SELECT username FROM users WHERE userid = ?", user_id).first
    if usernamedisplay != nil
        usernamedisplay = usernamedisplay["username"]
    end
    slim(:error,locals:{usernamedisplay:usernamedisplay})
end

get('/register') do 

    user_id = session[:user_id]
    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true
    usernamedisplay = db.execute("SELECT username FROM users WHERE userid = ?", user_id).first
    if usernamedisplay != nil
        usernamedisplay = usernamedisplay["username"]
    end
    slim(:register,locals:{usernamedisplay:usernamedisplay})

end
get '/login' do 

    user_id = session[:user_id]
    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true
    usernamedisplay = db.execute("SELECT username FROM users WHERE userid = ?", user_id).first
    if usernamedisplay != nil
        usernamedisplay = usernamedisplay["username"]
    end
    slim(:login,locals:{usernamedisplay:usernamedisplay})
end

get '/logout' do

    session[:user_id] = nil
    
    redirect('/')
end

get('/admin') do
    user_id = session[:user_id]
    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true
    usernamedisplay = db.execute("SELECT username FROM users WHERE userid = ?", user_id).first
    if usernamedisplay != nil
        usernamedisplay = usernamedisplay["username"]
    end



    slim(:admin,locals:{usernamedisplay:usernamedisplay})
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


post('/showlogin') do

    username = params[:username]
    password = params[:password]

    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true

    result = db.execute("SELECT userid, password_digest FROM users WHERE username=?", username)

    if result.empty?
        redirect('/error')
    end                 

    user_id = result.first["userid"]    
    password_digest = result.first["password_digest"]
    
    if BCrypt::Password.new(password_digest) == password
        session[:user_id] = user_id
        redirect('/')
    else
        set_error("Ivalid Credentials")
        redirect('/error')
    end
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
    user_id = session[:user_id]
    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true
    food_items = db.execute("SELECT foodId, foodTitle, Votes FROM foodtable")
    
    
    
    usernamedisplay = db.execute("SELECT username FROM users WHERE userid = ?", user_id).first
    if usernamedisplay != nil
        usernamedisplay = usernamedisplay["username"]
    end

    slim(:food,locals:{foodvariable:food_items, usernamedisplay:usernamedisplay})
    
end

post('/food/new') do
    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true

    newfood = params[:newfood]

    db.execute("INSERT INTO foodtable(foodTitle, Votes) VALUES (?,0)", newfood)
    redirect('/food')

end


post('/foodvotes/:id') do 

    db = SQLite3::Database.new("db/dbSlutprojekt.db")
    db.results_as_hash = true

    id = params[:id]
    result = db.execute("SELECT Votes FROM foodtable WHERE foodId = ?", id).first
    votes = result["Votes"]
    p votes

    votes += 1
    
    db.execute("UPDATE foodtable SET Votes = ? WHERE foodId = ?", votes, id)

    redirect('/food')

end

