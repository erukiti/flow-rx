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

class TweetPostViewModel
  constructor: (screenName) ->
    @text = wx.property ''
    @client = null
    @length = wx.property 140
    @client = wx.property null
    @screenName = wx.property screenName
    @placeholder = wx.property "ツイート @#{screenName}"
    @template = '''
      <div class="post">
        <textarea data-bind="textInput: @text, attr: {placeholder: placeholder}"></textarea>
        残り <span data-bind="text: length"></span>
        <button data-bind="command: post">tweet</button>
      </div>
    '''

    @post = wx.command =>
      console.log 'post'
      @client().post 'statuses/update', {status: @text()}, (err, tweet, response) =>
        if err
          console.error 'tweet error'
          console.dir err
        else
          @text('')

  setClient: (client) ->
    @client(client)


TwitterAuthentication = require './twitter_authentication.coffee'
TweetViewModel = require './tweet_view_model.coffee'
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
    @backgoundColor = wx.property ''
    @color = wx.property ''
    @client = wx.property null

    @config = config

    @authentication = new TwitterAuthentication()
    @authentication.observable.subscribe (packet) =>
      console.dir JSON.parse(JSON.stringify(packet))
      @name(packet.account.name)
      @screenName(packet.account.screen_name)
      @backgoundColor(packet.account.profile_background_color)
      @color(packet.account.profile_link_color)
      @client(packet.client)
    @authentication.get @config.id

    @tweetPostViewModel = new TweetPostViewModel(@screenName())

  connect: ->
    console.log 'TwitterFlow#connect'

    @subject.onNext {
      type: 'title'
      title: "Twitter @#{@name()}"
      color: "##{@color()}"
      backgoundColor: "##{@backgoundColor()}"
    }

    @subject.onNext {
      type: 'top'
      viewModel: @tweetPostViewModel
    }

    Rx.Observable.just(@client()).merge(@client.changed).subscribe (client) =>
      @tweetPostViewModel.setClient client
      client.get 'statuses/home_timeline', (err, tweets, response) =>
        for data in tweets
          tweet = new Tweet(data)
          @subject.onNext {
            type: 'item'
            item: new TweetViewModel(tweet)
            newer: false
          }

      client.stream 'user', {}, (stream) =>
        stream.on 'data', (data) =>
          if data.text
            tweet = new Tweet(data)
            @subject.onNext {
              type: 'item'
              item: new TweetViewModel(tweet)
              newer: true
            }
          else
            console.dir JSON.parse(JSON.stringify(data))

module.exports = TwitterFlow
