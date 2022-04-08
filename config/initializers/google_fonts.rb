uri = URI("https://www.googleapis.com/webfonts/v1/webfonts?key=#{ENV['GOOGLE_API_KEY']}")
res = Net::HTTP.get_response(uri)
GOOGLE_FONTS = JSON.parse(res.body)["items"].map { |font| font["family"] }.freeze
