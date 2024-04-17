#!/usr/bin/env ruby
# encoding: utf-8

require 'cgi'
require 'cgi/session'

cgi = CGI.new
session = CGI::Session.new(cgi)
session['favorite'] = (session['favorite'] || [])
if !session['favorite'].include?(cgi['lib'])
    session['favorite']<<cgi['lib']
end
print cgi.header("text/html; charset=utf-8")
puts <<EOF
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="./libsearch.css">

</head>
<body>
<div class="parent">
<div id="con">
<h1>お気に入りに追加しました</h1>
<p><a href="./index.rb">検索に戻る</a></p>
</div>
</div>
</body>
</html>
EOF