#!/usr/local/bin/ruby -Ku
require 'open-uri'
require 'cgi'
require 'rexml/document'

module TabelogRestaurantSearch
  class RestaurantSearchClient
    REQUEST_URI = 'http://api.tabelog.com/Ver2.1/RestaurantSearch/?Key=26ee9332a2be3e092e5a593bf254bd9d96bdb273&
        ResultSet=large&
        SortOrder=totalscore&'
    PRICE = { " ～￥999" => 1,
              "￥1,000 ～￥1,999" => 2,
              "￥2,000 ～￥2,999" => 3,
              "￥3,000 ～￥3,999" => 4,
              "￥4,000 ～￥4,999" => 5,
              "￥5,000 ～￥5,999" => 6,
              "￥6,000 ～￥7,999" => 7,
              "￥8,000 ～￥9,999" => 8,
              "￥10,000 ～￥14,999" => 9,
              "￥15,000 ～￥19,999" => 10,
              "￥20,000 ～￥29,999" => 11,
              "￥30,000 ～" => 12
            }
    include REXML

    # メール内容からXML情報を取得して処理
    class Result
      def initialize(i)
        @rcd = i.text('Rcd')
        
        @restaurant_name = i.text('RestaurantName')
        rst_no = i.text('TabelogUrl').split(/\//).last
        @url = "http://m.tabelog.com/rst_mobile/rstdtl?rcd=" + rst_no
        @total_score = i.text('TotalScore')
        @taste_score = i.text('TasteScore')
        @service_score = i.text('ServiceScore')
        @mood_score = i.text('MoodScore')
        @situation = i.text('Situation')

        # ランチ、ディナーの価格が設定されている場合、Priceのid番号に置き換える
        if PRICE[i.text('DinnerPrice')]
          @dinner_price = PRICE[i.text('DinnerPrice')]
        else
          @dinner_price = 13
        end
        if PRICE[i.text('LunchPrice')]
          @lunch_price = PRICE[i.text('LunchPrice')]
        else
          @lunch_price = 13
        end

        @category = i.text('Category')
        @station = i.text('Station')
        @address = i.text('Address')
        @tel = i.text('Tel')

        # 営業時間のXMLが改行されている場合、改行を解除
        if i.text('BusinessHours')
          # original = i.text('BusinessHours').gsub!('～', '-')
          # if original
          #   business_hours = ''
          #   original.split(/\r?\n/).each do |hour|
          #     business_hours += hour + ' '
          #   end
          #   @business_hours = business_hours.rstrip
          # end
          i.text('BusinessHours').split(/\r?\n/).each do |hour|
            @business_hours += hour + ' '
          end
        else
          @business_hours = nil
        end
        
        @holiday = i.text('Holiday')
        @latitude = i.text('Latitude')
        @longitude = i.text('Longitude')
      end
      attr_reader :name, :url, :total_score, :taste_score, :service_score, :mood_score, :situation,
          :dinner_price, :lunch_price, :category, :station, :address, :tel, :business_hours, :holiday,
          :latitude, :longitude
    end

    # 'station'がDBに未登録の場合、Tabelogにアクセスして、店舗リストを取得
    def self.request_restaurants(station)
      result = []
      pagenum = 1
      request(station, pagenum) do |i|
        result << Result.new(i)
      end
      if @num_of_result % 20 == 0
        while pagenum < @num_of_result / 20
          pagenum += 1
          request(station, pagenum) do |i|
            result << Result.new(i)
          end
        end
      elsif @num_of_result >= 20
        while pagenum < @num_of_result / 20 + 1
          pagenum += 1
          request(station, pagenum) do |i|
            result << Result.new(i)
          end
        end
      end
      return result
    end

    # tabelogにアクセスして、店舗リストの１ページを取得
    def self.request(station, pagenum, option = '')
      doc = nil
      begin
        open("#{REQUEST_URI}Station=#{CGI.escape station}&PageNum=#{pagenum}#{option}") do |uri|
          doc = Document.new(uri)
          doc = nil unless doc.root.text('Item')
        end
      rescue
        p $! if $DEBUG
      end
      if doc
        @num_of_result = doc.root.text('NumOfResult').to_i
        doc.root.each_element('Item') do |i|
          yield i
        end
      end
    end

    private

    # def create_result(station, pagenum)
    #   request(station, pagenum) do |i|
    #     result << Result.new(i)
    #   end
    # end
  end
end

if $0 == __FILE__
 require 'iconv'
 if ARGV.length == 0
   require 'test/unit'
   class TestRestaurantSearchClient < Test::Unit::TestCase
     def test_should_request_new_station
       shops = TabelogRestaurantSearch::RestaurantSearchClient.request_restaurants '三軒茶屋'
       assert_equal 315, shops.length
       shops.each do |shop|
         if shop.business_hours
           splitted = shop.business_hours.split(/\r?\n/)
           splitted.each do |split|
             business_hours = ''
             business_hours += business_hours + split + ' '
             assert(business_hours.length, 1)
           end
         end
       end
     end
   end
 else
   # ARGV[1..-1].each do |address|
   #   YahooWebService::LocalSearchClient.find ARGV[0], Iconv.conv('utf-8', 'shift_jis', address) do |i|
   #     puts Iconv.conv('shift_jis', 'utf-8', i.get_text('Title').value)
   #     puts "latitude=#{i.get_text('DatumTky97/Lat').value}, longitude=#{i.get_text('DatumTky97/Lon').value}"
   #   end
   # end
 end
end
