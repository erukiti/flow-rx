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

shell = require 'shell'

Tweet = require './tweet.coffee'

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
    @profileLinkColor = wx.property "##{tweet.user.profileLinkColor}"
    @profileBackgroundColor = wx.property "##{tweet.user.profileBackgroundColor}"
    if tweet.retweetedBy
      @retweetedByIcon = wx.property tweet.retweetedBy.profileImageUrlHttps
      @retweetedBy = wx.property "#{tweet.retweetedBy.name} @#{tweet.retweetedBy.screenName}"
    else
      @retweetedByIcon = wx.property ''
      @retweetedBy = wx.property ''

    @urls = wx.list()
    for url in tweet.urls
      @urls.push {
        displayUrl: url.display_url
        expandedUrl: url.expanded_url
      }

    @mediaUrls = wx.list()
    for media in tweet.media
      @mediaUrls.push {
        displayUrl: media.display_url
        mediaUrl: media.media_url
      }

    @template = wx.property """
      <div class="horizontal tweet">
        <div class="profile">
          <div>
            <img data-bind="attr: {src: icon}" class="avatar">
          </div>
          <div data-bind="visible: retweetedByIcon">
            <img data-bind="attr: {src: retweetedByIcon}" class="retweet-avatar">
            <span class="fa fa-retweet"></span>
          </div>
        </div>
        <div class="body">
          <div>
            <span data-bind="text: name" class="name"></span>
            <span data-bind="text: screenName" class="screen-name"></span>
          </div>
          <div class="text">
            <span data-bind="text: text"></span>
          </div>
          <div class="urls" data-bind="foreach: urls">
            <a data-bind="command: {command: $parent.link, parameter: expandedUrl}">
              <span class="fa fa-external-link"> <span data-bind="text: displayUrl"></span>
            </a>
          </div>
          <div class="media-urls" data-bind="foreach: mediaUrls">
            <div>
              <img data-bind="attr: {src: mediaUrl}, command: {command: $parent.link, parameter: mediaUrl}">
            </div>
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
            <span class="action" data-bind="command: {command: etc, parameter: $data}">…</span>

          </div>
          <div class="retweeted-by" data-bind="visible: retweetedBy">
            retweeted by
            <span data-bind="text: retweetedBy"></span>
          </div>

        </div>
      </div>
    """

    @etc = wx.command (data) =>
      console.dir data.tweet

    @link = wx.command (url) =>
      console.dir "open: #{url}"
      shell.openExternal url

    @id = tweet.id

module.exports = TweetViewModel
