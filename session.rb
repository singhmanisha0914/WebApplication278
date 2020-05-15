require 'sinatra'
require './account'

configure do
  # set the session true
  enable :sessions
end

configure :development do
#setup sqlite database
end

configure :production do
setup ENV[…] database
end

#defining route for the webpage
get '/' do
  redirect '/login'
end

#defining route for getting the login page
get '/login' do
  if session[:login]
    erb :visit, :layout => :'narrow_layout'
  else
    erb :login
  end
end

#defining route for posting the login page
post '/login' do
  #get the user account details from the user database
  @userAccount = Account.first(username: params[:username])
  if @userAccount.nil?
	session[:message] = "username not registered! Please register to play."
    redirect '/login'
  else 
    if params[:username] == @userAccount.username && params[:password] == @userAccount.password
      #set the current user variable
	  $curUser = params[:username]
      session[:login] = true
      session[:name] = params[:username]
	  session[:profit] = 0
	  session[:win] = 0
	  session[:lost] = 0
	  #set betPlaced flag to false
	  $betPlaced = false
	  #get the user account details related to total win, loss, and profit from the user database
	  @accounts = Account.first(username: params[:username])
	  $acctTotWin = @accounts.totWin
	  $acctTotLoss = @accounts.totLoss
	  $acctTotProfit = @accounts.totProfit
      erb :visit
    else
      session[:message] = "username and password does not match"
      redirect '/login'
    end
  end	
end

post '/betting' do
  if params[:diceNumber].to_i > 0 && params[:diceNumber].to_i < 7
    #set betPlaced flag to true
    $betPlaced = true
    stake = params[:betAmount].to_i
    number = params[:diceNumber].to_i
    roll = rand(6) + 1
    session[:diceLandedOn] = roll
    if number == roll
     save_session(:win, 10 * stake)
	%{The dice landed on #{roll}, you win #{10*stake} dollars,
      total win is #{session[:win]} dollars}
    else
    save_session(:lost, stake)
    %{The dice landed on #{roll}, you lost #{stake} dollars,
      total lost is #{session[:lost]} dollars}
    end	
    session[:profit] = (session[:win].to_i - session[:lost].to_i)
    erb :visit
  
  else
    #set invalidInput flag to true
    $invalidInput = true
    $invalidBet = "Invalid bet number!! Please place your bet on a number between 1 to 6."
	erb :visit
  end
end

#defining function to save the session win and loss amounts
def save_session(won_lost, money)
  count = (session[won_lost] || 0).to_i
  count += money
  session[won_lost] = count
end

#defining route for the logout
get '/logout' do
  #get the user account details from the user database
  @account = Account.first(username: $curUser)
  #update the user's win/loss details to the database
  $acctWinPostSession = $acctTotWin.to_i + session[:win].to_i
  $acctLosPostSession = $acctTotLoss.to_i + session[:lost].to_i
  $acctProfPostSession = $acctTotProfit.to_i + session[:profit].to_i
  #update user's new total win, total loss, and total profit
  @account.update(totWin: $acctWinPostSession.to_i)
  @account.update(totLoss: $acctLosPostSession.to_i)
  @account.update(totProfit: $acctProfPostSession.to_i)
  #resetting the session values
  session[:login] = nil
  session[:name] = nil
  session[:message] = "You have sucessfully logged out"
  redirect '/login'
end

not_found do
  "Please enter a valid URL"
end

