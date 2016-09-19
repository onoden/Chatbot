class TokensController < ApplicationController
  protect_from_forgery with: :null_session, if: ->{request.format.json?}
  def index
    if params["hub.verify_token"] == "EAAYq0g6YzFcBABj215kItqhn2XwjqZAjDcdEDXiCHivERslw3aHFGZBoYoDmbwpTeAxqn5onvTrCc6FI5k5bupvF8gcrmNqLHA9u7XrX5ZCZCkxToU9qfAzhAYonM8IyQ7LxqZBxIbpC9ZAcvDQiE53ONqWt7maVq0mX1YyCpYEAZDZD"
      callback
    else
      render json: "Error, wrong validation token"
      # render json: params["hub.challenge"]
    end
  end

  def callback
    token = "EAAYq0g6YzFcBABj215kItqhn2XwjqZAjDcdEDXiCHivERslw3aHFGZBoYoDmbwpTeAxqn5onvTrCc6FI5k5bupvF8gcrmNqLHA9u7XrX5ZCZCkxToU9qfAzhAYonM8IyQ7LxqZBxIbpC9ZAcvDQiE53ONqWt7maVq0mX1YyCpYEAZDZD"

    message = params["entry"][0]["messaging"][0]

    p message

    if message.include?("message")

      p "messageあった"

      #ユーザーの発言

      sender = message["sender"]["id"]
      text = message["message"]["text"]

      endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token=" + token
      request_content = {recipient: {id:sender},
                         message: {text: text}
      }

      content_json = request_content.to_json

      RestClient.post(endpoint_uri, content_json, {
          'Content-Type' => 'application/json; charset=UTF-8'
      }){ |response, request, result, &block|
        p response
        p request
        p result
      }

      p "post完了"
    else
      #botの発言
    end
  end

end
