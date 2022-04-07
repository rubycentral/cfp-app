class ImageUploadsController < ApplicationController
  skip_forgery_protection
  before_action :require_user

  def create
    blob = ActiveStorage::Blob.create_after_upload!(
      io: params[:file],
      filename: params[:file].original_filename,
      content_type: params[:file].content_type
    )

    render json: {location: url_for(blob)}, content_type:  "text / html"
  end
end
