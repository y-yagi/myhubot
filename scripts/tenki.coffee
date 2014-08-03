jsdom = require 'jsdom'

module.exports = (robot) ->
  robot.respond /天気 (.*)$/i, (msg) ->
    adapter  = msg.robot.adapter
    envelope = msg.envelope

    new_line = "<br>"
    api_url = 'http://weather.livedoor.com/forecast/rss/warn/'
    [area] = [msg.match[1]]

    areas = {
      北海道 : '01'
      青森 : '02', 岩手 : '03', 宮城 : '04', 秋田 : '05', 山形 : '06', 福島 : '07'
      茨城 : '08', 栃木 : '09', 群馬 : '10', 埼玉 : '11', 千葉 : '12', 東京 : '13', 神奈川 : '14'
      新潟 : '15', 富山 : '16', 石川 : '17', 福井 : '18', 山梨 : '19', 長野 : '20'
      岐阜 : '21', 静岡 : '22', 愛知 : '23', 三重 : '24'
      滋賀 : '25', 京都 : '26', 大阪 : '27', 兵庫 : '28', 奈良 : '29', 和歌山 : '30'
      鳥取 : '31', 島根 : '32', 岡山 : '33', 広島 : '34', 山口 : '35'
      徳島 : '36', 香川 : '37', 愛媛 : '38', 高知 : '39'
      福岡 : '40', 佐賀 : '41', 長崎 : '42', 熊本 : '43', 大分 : '44', 宮崎 : '45', 鹿児島 : '46', 沖縄 : '47'
    }

    area_id = areas[area]
    unless area_id?
      adapter.sendHTML envelope, "#{area}という場所は無いよ! 都道府県を指定してね!"
      return

    adapter.sendHTML envelope, 'ちょっと待ってね...'

    msg.http(api_url + area_id + ".xml")
       .get() (err, res, body) ->
          status = res.statusCode
          try
            reply = ''
            xml = jsdom.jsdom(body)
            for item, i in xml.getElementsByTagName("rss")[0].getElementsByTagName("channel")[0].getElementsByTagName("item")
              continue if i == 0  # 最初に広告のデータが入る

              do (item) ->
                title = item.getElementsByTagName("title")[0].childNodes[0].nodeValue
                descriptionNode = item.getElementsByTagName("description")[0]
                description = descriptionNode.childNodes[0].nodeValue if descriptionNode.childNodes.length == 1
                reply += " - #{title},"
                reply += " #{description}" if description?
                reply += new_line
          catch err
                msg.send err

          adapter.sendHTML "「#{area}」の警報・注意報発表情報"
          adapter.sendHTML reply
