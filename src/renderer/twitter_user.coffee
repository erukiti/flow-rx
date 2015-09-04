class TwitterUser
  _users = {}

  @create = (data) =>
    _users[data.id] = new TwitterUser(data) unless _users[data.id]

    _users[data.id]

  constructor: (data) ->
    # contributors_enabled
    @createdAt = data.created_at
    @defaultProfile = data.default_profile
    @defaultProfileImage = data.default_profile_image
    @description = data.description
    @favouritesCount = data.favorite_count
    # follow_request_sent
    @followersCount = data.followers_count
    @following = data.following
    @friendsCount = data.friends_count
    # geo_enabled
    @id = data.id
    @idStr = data.id_str
    @isTranslator = data.is_translator
    @lang = data.lang
    @listedCount = data.listed_count
    @location = data.location
    @name = data.name
    @notifications = data.notifications

    @profileBackgroundColor = data.profile_background_color

    # profile_background_image_url
    # profile_background_image_url_https
    # profile_background_tile
    # profile_banner_url
    # profile_image_url
    @profileImageUrlHttps = data.profile_image_url_https
    # profile_link_color
    # profile_sidebar_border_color
    # profile_sidebar_fill_color: (...)
    # profile_text_color: (...)
    # profile_use_background_image: (...)
    @protected = data.protected
    @screenName = data.screen_name
    @statusesCount = data.statuses_count
    @timeZone = data.time_zone
    @url = data.url
    @utcOffset = data.utc_offset
    @verified = data.verified

module.exports = TwitterUser
