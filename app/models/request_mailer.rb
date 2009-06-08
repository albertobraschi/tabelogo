class RequestMailer < ActionMailer::Base

  def receive(mail)
    return nil unless mail.from
    if user = check_from(mail)
      # GPS情報を取得
      mdata = /(.+?)(NKF.nkf('-j', "【GPS情報】"))?\r?\n[^\n]*?\/(walk\.eznavi|docomo\.ne).jp\/.+?lat=.*?([\d.]+?)&lon=.*?([\d.]+?)&/m.match(mail.body)
      # ソフトバンク 地図表示: http://map.navitime.jp?pos=N35.34.54.28E139.39.48.22&x-acr=1&geo=wgs84

      if mdata
        lines = [wgs84_to_tokyo(to_degree(mdata[4]), to_degree(mdata[5])), mdata[1].strip]
      else
        unless mail.body.empty?
          lines = mail.body.split(/\r?\n/)
        else
          PostOffice.deliver_format_error(mail.body, mail.from)
        end
      end

      if lines.length >= 2
        # location「駅」が含まれる場合、これを除く
        if /駅$/ =~ lines[0]
          lines[0].gsub!(/駅$/, "")
        end

        station  = lines[0].strip
        category = lines[1].strip

        # メールのstationが登録済みかどうかで処理を分岐
        begin
          station_id = Station.find(:first, :conditions => ['name = ?', station]).id
          # DBにstationの登録が無い場合
          if station_id == nil
            # 新規にtabelogのAPIに問い合わせを行う
            station_id = search_new_station(station)
          end
          # 駅名が検索できた場合
          unless station_id == nil
            shop = recommend(station_id, category, mail.from)
            create_request(user, shop, station_id, category) if shop
          else # stationで駅名が検索できない場合、「見つかりませんでした」のメッセージを送信
            PostOffice.deliver_location_error(station, category, mail.from)
          end
        rescue => error # 処理過程のエラー
          PostOffice.deliver_fatal_error(error, station, category, mail.from)
        end

      # メールのフォーマットが不正の場合
      else
        PostOffice.deliver_format_error(mail.body, mail.from)
      end

    # PCからのメールの場合
    else
      PostOffice.deliver_pc_error(mail.from)
    end

  end

  private

  # ユーザー登録の有無、モバイルからのメールかを判別
  def check_from(mail)
    user = User.find :first, :select => 'id, email', :conditions => ['upper(email) = ?', mail.from[0].upcase]
    if user == nil and /(ezweb|softbank|vodafone|docomo|pdx)\.ne\.jp|softbank\.jp/ =~ mail.from[0]
      user = User.create :email => mail.from[0], :crypted_password => "4abb785d9682d9fbd5bda5a60f37864398d93090"
    end
    return user
  end

  # tabelogのAPIに駅名で新規問い合わせ
  def search_new_station(station)
    results = TabelogRestaurantSearch::RestaurantSearchClient.request_restaurants(station)
    # 検索結果が返った場合はstation、shopテーブルにデータを登録
    unless results.length == 0
      new_station = Station.create :name => station
      results.each do |result|
        Shop.create :rcd => result.rcd,
                    :restaurant_name => result.restaurant_name,
                    :tabelog_url => result.tabelog_url,
                    :tabelog_mobile_url => result.tabelog_mobile_url,
                    :total_score => result.total_score,
                    :taste_score => result.taste_score,
                    :service_score => result.service_score,
                    :mood_score => result.mood_score,
                    :situation => result.situation,
                    :dinner_price => result.dinner_price,
                    :lunch_price => result.lunch_price,
                    :category => result.category,
                    :station_id => result.station_id,
                    :tel => result.tel,
                    :business_hours => result.business_hours,
                    :holiday => result.holiday,
                    :latitude => result.latitude,
                    :longitude => result.longitude
      end
      return new_station.id
    end
  end

  def create_request(user, shop, station_id, category)
    Request.create  :user_id => user.id,
                    :shop_id => shop.id,
                    :station_id => station_id,
                    :category => category
  end

  def recommend(station, category, sender)
    user_id = User.find(:first, :conditions => ['email = ?', sender]).id
    station_id = Station.find(:first, :conditions =>['name = ?', station]).id

    # コンプリート機能
    total_shops = Shop.find(:all, :conditions => ['station_id = ? and category like ?',
        station_id, "%#{category}%"]).length
    done_memos = Memo.find(:all, :conditions => ['user_id = ? and location = ? and text like ?',
        user_id, station, "%#{category}%"])
    done_shops = []
    done_memos.each do |memo|
      done_shops << memo.shop_id
    end

    # 他人が検索したcategoryをレコメンド
    categories = []
    other_categories = []
    other_num = 0
    other_memos = Memo.find(:all, :conditions => ['location = ?', station])
    if other_memos.length > 0
      other_memos.each do |memo|
        categories << memo.text
      end
      other_num = categories.uniq.length
      other_categories = categories.uniq
    end

    others = ""
    i = 0
    while i < other_num
      if other_categories[i] != category
        if i == 0
          others += "「" + other_categories[i] + "」"
        else
          others += "、「" + other_categories[i] + "」"
        end
      end
      i += 1
    end

    if done_shops.length < total_shops
      i = 0
      while i < total_shops
        shop = Shop.find(:first, :order => 'total_score DESC', :offset => i,
            :conditions => ['station_id = ? and category like ?', station_id, "%#{category}%"])
        i += 1
        unless done_shops.include?(shop.id)
          break
        end
      end
    else
      j = rand(total_shops)
      shop = Shop.find(:first, :order => 'total_score DESC', :offset => j,
          :conditions => ['station_id = ? and category like ?', station_id, "%#{category}%"])
    end

    if shop
      dinner = Price.find(shop.dinner_price)
      lunch = Price.find(shop.lunch_price)
      PostOffice.deliver_answer(station, category, shop, sender, dinner, lunch,
          total_shops, done_shops.length + 1, others)
      return shop
    else # categoryが不正の場合
      PostOffice.deliver_fail(station, category, sender)
    end
  end

  def to_degree(s)
    a = s.split(/[.\/]/)
    if a.lenght <= 2
      return s.to_f
    elsif a.lenght == 4
      a[2] = "#{a[2]}.#{a[3]}"
    end
    a[0].to_f + a[1].to_f / 60 + a[2].to_f / 3600
  end

  def wgs84_to_tokyo(b, l)
    lat = b + 0.00010696 * b - 0.000017467 * l - 0.0046020
    lon = l + 0.000046047 * b + 0.000083049 * l - 0.010041
    sprintf "GPS:%.5f,%.5f", lat, lon
  end

end
