class TokensController < ApplicationController
  protect_from_forgery with: :null_session, if: ->{request.format.json?}
  before_action :initialize_items
  def index
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
    if text =~ /今日の出費は？/
      res_text = text
      sum = 0
      if Expense.all.present?
        Expense.all.each do |e|
          sum += e.price
        end
        res_text = "#{sum}円だよー"
      else
        "0円だよー"
      end
    elsif text =~ /さっきの記録消して/
      if Expense.all.present?
        Expense.all.first.delete
        res_text = "全消ししたよー"
      end
    elsif text =~ /記録全部消して/
      Expense.delete_all
      res_text = "記録全消し"
    else
      res_text = response_text(text)
    end
    {
        recipient: {
            id: sender
        },
        message: {
            text: res_text
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
      else
        #botの発言
      end
    end
  end

  private

  def initialize_items
    @natto = Natto::MeCab.new
    @expense = Expense.new
  end

  def response_text(text)
    price_words = []
    item_words = []
    @natto.parse(text) do |n|
      if n.feature =~ /名詞,数/
        price_words << n.surface
      elsif n.feature =~ /名詞,一般/
        item_words << n.surface
      end
    end
    res_text = response_invalid_input(price_words, item_words)
    if res_text.nil?
      saved_record(price_words, item_words)
      res_text = "記録したよー"
      res_text
    end
  end

  def response_invalid_input(price_words, item_words)
    if price_words.blank? || item_words.blank?
      res_text = "買ったものと金額教えてー"
      res_text
    else
      if price_words.size > 1 || item_words.size > 1
        res_text = "正しく入力してー"
        res_text
      else
        nil
      end
    end
  end

  def saved_record(price_words, item_words)
    @expense.name = item_words[0]
    @expense.price = price_words[0]
    @expense.save
  end

end
