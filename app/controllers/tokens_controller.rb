class TokensController < ApplicationController
  protect_from_forgery with: :null_session, if: ->{request.format.json?}
  def index
    # if params["hub.verify_token"] == "hogehoge"
    #   render json: params["hub.challenge"]
    # else
    #   render json: "Error, wrong validation token"
    # end
    callback
  end

  def bot_response(sender, text)
    request_endpoint = "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV["FACEBOOK_PAGE_TOKEN"]}"
    request_body = text_message_request_body(sender, text)
    RestClient.post(request_endpoint, request_body, {
        'Content-Type' => 'application/json; charset=UTF-8'
    }){ |response, request, result, &block|
      p response
      p request
      p result
    }
  end

  def text_message_request_body(sender, text)
    @text = text
    natto = Natto::MeCab.new
    natto.parse(@text) do |n|
      if n.surface =~ /\d+円?/
        @text = "記録したよ"
      end
    end
    {
        recipient: {
            id: sender
        },
        message: {
            text: @text
        }
    }.to_json
  end

  def callback
    unless params["entry"].nil?
      message = params["entry"][0]["messaging"][0]
      if message.include?("message")
        #ユーザーの発言
        sender = message["sender"]["id"]
        text = message["message"]["text"]
        bot_response(sender, text)
        # endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token=" + token
        # request_content = {recipient: {id:sender},
        #                    message: {text: text}
        # }
        # content_json = request_content.to_json
        # RestClient.post(endpoint_uri, content_json, {
        #     'Content-Type' => 'application/json; charset=UTF-8'
        # }){ |response, request, result, &block|
        #   p response
        #   p request
        #   p result
        # }
      else
        #botの発言
      end
    end
  end

end
