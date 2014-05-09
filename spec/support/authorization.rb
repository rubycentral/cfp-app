def login(person)
  session[:uid] = person.id
end

def logout
  session[:uid] = nil
end
