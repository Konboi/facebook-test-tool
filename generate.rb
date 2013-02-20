# -*- coding: utf-8 -*-
require 'rubygems'
require 'csv'
require 'faraday'
require 'yaml'
require 'json'

# load config 
config = YAML.load_file("config/config.yml")

url        = config["facebook"]["url"]
app_id     = config["facebook"]["app_id"]
app_secret = config["facebook"]["app_secre"]


def which_gender(gender=nil)
  if gender == "男"
    return 1
  else
    return 2
  end
end

datas = []
count = 0

# データの作成
CSV.foreach("data/dummy.csv") do |row|
  #先頭行を読みこまない用に
  count +=1
  next if count == 1

  gender = which_gender(row[2])
  datas.push({
      name: row[0],
      gender: gender
    })
end

conn = Faraday.new(:url => url) do |builder|
  builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
  builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
  builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
end

#app_access_token の取得
# https://developers.facebook.com/docs/technical-guides/opengraph/publishing-with-app-token/
result = conn.get do |req|
  req.url "oauth/access_token", { :client_id => config["facebook"]["app_id"] }

  req.params[:client_secret] = config["facebook"]["app_secret"]
  req.params[:grant_type] = :client_credentials
end

app_access_token = result.body.split("=")[1]

# テストユーザー一覧取得
# 
result = conn.get do |req|
  req.url "#{app_id}/accounts/test-users"
  req.params[:access_token] = app_access_token
end

test_users = JSON.parse(result.body)["data"]

test_users.each do |test_user|
  puts test_user["access_token"]
  puts test_user["id"]
end

=begin
# テストユーザー作成
datas.each do |data|
  result = conn.get do |req|
    req.url "#{app_id}/accounts/test-users", {:installed => :true }

    req.params[:name]         = :"#{data[:name]}"
    req.params[:locale]       = :ja_JP
    req.params[:permissions]  = :read_stream
    req.params[:method]       = :post
    req.params[:access_token] = "#{app_access_token}"
  end
end

#test_user = JSON.parse(result.body)
#p test_user
# 
#CSV.open("data/users.csv") do |write|
#  write << ["facebook_id", "name", "password" , "access_token", "login_url"]
#  write << [test_uesr["id"], datas.first["name"], test_user["password"], test_user["access_token"], test_user["login_url"]]
#end

=end
