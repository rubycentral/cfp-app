def login(user)
  session[:uid] = user.id
end

def logout
  session[:uid] = nil
end
