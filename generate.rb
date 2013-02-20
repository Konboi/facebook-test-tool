# -*- coding: utf-8 -*-
require 'rubygems'
require 'csv'
require 'faraday'
require 'yaml'


# load config 
config = YAML.load_file("config/config.yml")

url        = config["facebook"]["url"]
app_id     = config["facebook"]["app_id"]
app_secret = config["facebook"]["app_secre"]


$APP_ACCESS_TOKEN = "108446559324267|r2Jcg36Qg5LD8Ay0iVQvUTvjwks"

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

datas.each do |data|
  conn.get do |req|
    req.url "#{app_id}/accounts/test-users", {:installed => :true }

    req.params[:name]         = :"#{data[:name]}"
    req.params[:locale]       = :ja_JP
    req.params[:permissions]  = :read_stream
    req.params[:method]       = :post
    req.params[:access_token] = "#{$APP_ACCESS_TOKEN}"
  end
end

