TwitterUser = require './twitter_user.coffee'

class Tweet
  _clientRegexp = new RegExp('^<a href="(.*)" rel="nofollow">(.*)</a>$')
  constructor: (data) ->
    @data = JSON.parse(JSON.stringify(data))

    if data.retweeted_status
      @retweetedBy = TwitterUser.create(data.user)

      data = data.retweeted_status

    @createdAt = data.created_at
    @favoriteCount = data.favorite_count
    @favorited = data.favorited
    #filter_level
    #geo
    @id = data.id
    @idStr = data.id_str
    # in_reply_to_screen_name
    # in_reply_to_status_id
    # in_reply_to_status_id_str
    # in_reply_to_user_id
    # in_reply_to_user_id_str

    # is_quote_status
    @lang = data.lang
    @retweetCount = data.retweet_count
    @retweeted = data.retweeted
    @source = data.source

    @text = data.text
    # timestamp_ms
    @truncated = data.truncated

    @hashtags = data.entities.hashtags
    @symbols = data.entities.symbols
    @urls = data.entities.urls
    @user_mentions = data.entities.user_mentions

    @user = TwitterUser.create(data.user)

    matched = _clientRegexp.exec(@source)
    if matched
      @client = matched[2]
      @clientUrl = matched[1]

  inspect: ->
    console.dir @data

module.exports = Tweet
