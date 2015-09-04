# Copyright 2015 SASAKI, Shunsuke. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TwitterAuthentication = require './twitter_authentication.coffee'

class TweetViewModel
  constructor: (tweet) ->
    @tweet = tweet
    @icon = wx.property tweet.user.profileImageUrlHttps
    @text = wx.property tweet.text
    @name = wx.property tweet.user.name
    @screenName = wx.property "@#{tweet.user.screenName}"
    @retweetCount = wx.property tweet.retweetCount
    @favoriteCount = wx.property tweet.favoriteCount
    @client = wx.property tweet.client
    @profileBackgroundColor = wx.property "##{tweet.user.profileBackgroundColor}"

    @template = wx.property """
      <div class="horizontal tweet">
        <div class="profile" data-bind="style: {'background-color': profileBackgroundColor}">
          <img data-bind="attr: {src: icon}" class="avatar">
        </div>
        <div class="body">
          <div>
            <span data-bind="text: name" class="name"></span>
            <span data-bind="text: screenName" class="screen-name"></span>
          </div>
          <div class="text">
            <span data-bind="text: text"></span>
          </div>
          <div class="client">
            via 
            <span data-bind="text: client"></span>
          </div>
          <div class="ope">
            <span class="fa fa-retweet"></span>
            <span data-bind="text: retweetCount"></span>
            ☆
            <span data-bind="text: favoriteCount"></span>
            <span data-bind="command: {command: etc, parameter: $data}">…</span>

          </div>

        </div>
      </div>
    """

    @etc = wx.command (data) =>
      console.dir data.tweet

    @id = tweet.id

Tweet = require './tweet.coffee'
TwitterConfigViewModel = require './twitter_config_view_model.coffee'

class TwitterFlow
  @configViewModel = => new TwitterConfigViewModel()

  constructor: (config) ->
    @subject = new Rx.Subject()
    @observable = @subject.publish()
    @observable.connect()

    @name = wx.property ''
    @screenName = wx.property ''
    @client = wx.property null

    @config = config

    @authentication = new TwitterAuthentication()
    @authentication.observable.subscribe (packet) =>
      @name(packet.account.name)
      @screenName(packet.account.screen_name)
      @client(packet.client)
    @authentication.get @config.id

  connect: ->
    console.log 'TwitterFlow#connect'

    Rx.Observable.just(@client()).merge(@client.changed).subscribe (client) =>
      # @subject.onNext {
      #   type: 'title'
      #   title: "Twitter @"
      # }

      client.get 'statuses/home_timeline', (err, tweets, response) =>
        for data in tweets
          tweet = new Tweet(data)
          # tweet.inspect()
          @subject.onNext {
            type: 'item'
            item: new TweetViewModel(tweet)
            newer: false
          }

      client.stream 'user', {}, (stream) =>
        stream.on 'data', (data) =>
          if data.text
            tweet = new Tweet(data)
            # tweet.inspect()
            @subject.onNext {
              type: 'item'
              item: new TweetViewModel(tweet)
              newer: true
            }
          else
            console.dir JSON.parse(JSON.stringify(data))

FlowConfigViewModel = require './flow_config_view_model.coffee'

class Flow
  _klasses = {}
  @register = (name, klass) =>
    _klasses[name] = klass

  _configure = (config) ->
    @subscripten.dispose() if @subscripten
    flow = new _klasses[config.name](config)
    @subject.onNext {type: 'clear'}
    @subscripten = flow.observable.subscribe (packet) =>
      @subject.onNext packet

    flow.connect()

  constructor: (config) ->
    @config = config
    @subject = new Rx.Subject()
    @observable = @subject.publish()
    @observable.connect()
    @subscripten = null

  connect: ->
    if @config
      _configure.call @, @config
    else
      flowConfigViewModel = new FlowConfigViewModel(_klasses, @config)
      flowConfigViewModel.observable.subscribe (config) =>
        @config = config
        _configure.call @, config

      @subject.onNext {type: 'clear'}
      @subject.onNext
        type: 'item'
        item: flowConfigViewModel
        newer: true


Flow.register 'twtter', TwitterFlow

module.exports = Flow
