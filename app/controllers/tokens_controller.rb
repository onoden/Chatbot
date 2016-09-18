class TokensController < ApplicationController
  def index
    if params["hub.verify_token"] == "EAAYq0g6YzFcBABj215kItqhn2XwjqZAjDcdEDXiCHivERslw3aHFGZBoYoDmbwpTeAxqn5onvTrCc6FI5k5bupvF8gcrmNqLHA9u7XrX5ZCZCkxToU9qfAzhAYonM8IyQ7LxqZBxIbpC9ZAcvDQiE53ONqWt7maVq0mX1YyCpYEAZDZD"
      render json: params["hub.challenge"]
    else
      render json: "Error, wrong validation token"
    end
  end

end
