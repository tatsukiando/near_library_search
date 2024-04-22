#!/usr/bin/env ruby
# encoding: utf-8

require 'cgi'
require 'cgi/session'
require 'net/http'
require 'rexml/document'
require 'json'

cgi = CGI.new

# 住所を指定
address = cgi['address']
if address.match("^<.*>".length()>0)
  puts <<EOF
  <html>
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body>
  <h2>htmlタグは使用できません</h2>
  </body>
  </html>
EOF
end

# Geocoding.jp APIのURLを構築
url = URI("https://www.geocoding.jp/api/?q=#{URI.encode_www_form_component(address)}")

# HTTPリクエストを送信してレスポンスを取得
response = Net::HTTP.get(url)

# XMLを解析
doc = REXML::Document.new(response)

# HTTPヘッダーを出力
print cgi.header("text/html; charset=utf-8")

# HTMLコンテンツを出力
puts <<EOF
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="./libsearch.css">
  <title>結果</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
EOF

# 緯度経度を取得
latitude = doc.elements["result/coordinate/lat"]&.text
longitude = doc.elements["result/coordinate/lng"]&.text

if latitude && longitude
    calil = URI("https://api.calil.jp/library?appkey=013b0ddd619027eb3415b049b1af5890&geocode=#{URI.encode_www_form_component(longitude)},#{URI.encode_www_form_component(latitude)}&limit=1")
    calil_res = Net::HTTP.get(calil)
    doc = REXML::Document.new(calil_res)
    lib_geo_tmp = doc.elements["Libraries/Library/geocode"]&.text
    lib_name = doc.elements["Libraries/Library/formal"]&.text
    lib_url = doc.elements["Libraries/Library/url_pc"]&.text
    lib_add = doc.elements["Libraries/Library/address"]&.text

    lib_geo = lib_geo_tmp.split(',')
    pin_data = {"latitude" => lib_geo[1], "longitude" => lib_geo[0]}.to_json
    puts <<EOF
    <script>
    window.addEventListener("load",function(){
        var pinData = #{pin_data};
        var map = L.map('map').setView([pinData.latitude, pinData.longitude], 13);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);

        L.marker([pinData.latitude, pinData.longitude]).addTo(map).bindPopup('#{lib_name}').openPopup();
    });
    </script>
    </head>
    <body>
    <div id="nearlib">
    <h1>最寄りの図書館</h1>
    </div>
    <h2>#{lib_name}</h2>
    <p><a href="#{lib_url}">#{lib_url}</a></p>
    <p>#{lib_add}</p>
    <form action="./add.rb" method="post">
    <input type="hidden" name="lib" value="#{lib_name}">
    <input type="submit" class="btn_add" value="お気に入りに追加">
    
    <div id="map" style="text-align:center;"></div>
EOF
else
    puts "  <h2>位置情報取得に失敗しました。</h2>"
end

puts <<EOF
  <p><a href="./index.rb">検索に戻る</a></p>
</body>
</html>
EOF
