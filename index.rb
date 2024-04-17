#!/usr/bin/env ruby
# encoding: utf-8

require 'cgi'
require 'cgi/session'
cgi = CGI.new
session = CGI::Session.new(cgi)

session['favorite']=(session['favorite'] || [""])
print cgi.header("text/html; charset=utf-8")
print <<EOF
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="./libsearch.css">
<body>
<h1>
<p>最寄りの図書館検索</p>
</h1>
<form action="./result.rb" method="post">
<p>
<h2>住所を入力してください。</h2>
</p>
<p>
<input type="text" id="adr_input" name="address" placeholder="〇〇県△△市××">
</p>
<p>
<input type="submit" class="btn_search" value="検索">
</form>
</p>
<div id="list">
<h2>
<p color="black">お気に入り図書館リスト</p>
</h2>
<div>
EOF

session['favorite'].each{|lib|
  print <<EOF
  <p>#{lib}</p>
EOF
}
print <<EOF
<form action="./delete.rb" method="post">
<p><input type="submit" class="btn_delete" value="お気に入りをクリア"></p>
</form>
</body>
<html>
EOF
session.close