# frozen_string_literal: true

# Rejects requests that bypass CloudFront by verifying the X-Origin-Secret
# header added by CloudFront as a static custom origin header. The origin
# hostname is discoverable through Certificate Transparency logs, so direct
# access must be redirected to the canonical domain (APP_HOST).
#
# Verification is skipped entirely when CLOUDFRONT_ORIGIN_SECRET is not set,
# so the app can be brought up before CloudFront exists.
class OriginVerification
  def initialize(app)
    @app = app
    @secret = ENV["CLOUDFRONT_ORIGIN_SECRET"]
    @app_host = ENV["APP_HOST"]
  end

  def call(env)
    return @app.call(env) if @secret.blank?

    request = Rack::Request.new(env)
    # kamal-proxy health checks hit the container directly without the header.
    return @app.call(env) if request.path == "/up"

    given = env["HTTP_X_ORIGIN_SECRET"].to_s
    if Rack::Utils.secure_compare(given, @secret)
      @app.call(env)
    else
      Rails.logger.warn("OriginVerification: rejected path=#{request.path} ip=#{request.ip}")
      if request.get? || request.head?
        [301, { "location" => "https://#{@app_host}#{request.fullpath}" }, []]
      else
        [403, { "content-type" => "text/plain" }, []]
      end
    end
  end
end
