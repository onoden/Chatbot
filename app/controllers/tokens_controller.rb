class TokensController < ApplicationController
  def index
    if params["hub.verify_token"] == "hogehoge"
      render json: params["hub.challenge"]
    else
      render json: "Error, wrong validation token"
    end
  end

end
