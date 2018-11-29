OmniAuth.config.test_mode = true

def init_mock_omniauth
  OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
    provider: 'twitter',
    uid: 'test_omni_user',
    info: {
      nickname: 'test_omni_user',
      name: 'Test User'
    }
  })

  OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
    provider: 'github',
    uid: 'test_omni_user',
    info: {
      email: 'test@omniuser.com',
      nickname: 'test_omni_user',
      name: 'Test User'
    }
  })
end