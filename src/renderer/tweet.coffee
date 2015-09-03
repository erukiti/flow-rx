TwitterUser = require './twitter_user.coffee'

class Tweet
  _clientRegexp = new RegExp('^<a href="(.*)" rel="nofollow">(.*)</a>$')
  constructor: (data) ->
    @data = JSON.parse(JSON.stringify(data))

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
    # '<a href="http://twitter.com" rel="nofollow">Twitter Web Client</a>'
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
      console.dir matched
      @client = matched[2]
      @clientUrl = matched[1]
      # @client = matched

  inspect: ->
    console.dir @data

module.exports = Tweet
