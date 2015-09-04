remote = require 'remote'
BrowserWindow  = remote.require 'browser-window'
NodeTwitterApi = require 'node-twitter-api'
Twitter = remote.require 'twitter'

class TwitterAuthentication
  _consumerKey = remote.getGlobal 'consumerKey'
  _consumerSecret = remote.getGlobal 'consumerSecret'

  _cache = {}

  _createClient = (accessToken, accessTokenSecret) ->
    new Twitter
      consumer_key:         _consumerKey
      consumer_secret:      _consumerSecret
      access_token_key:     accessToken
      access_token_secret:  accessTokenSecret  

  _verifyCredential = (id, client, accessToken, accessTokenSecret) ->
    client.get 'account/verify_credentials', (err, account, response) =>
      if err
        console.error err
        console.dir err
        if id
          auths = JSON.parse(localStorage.getItem 'twitter-auth') || {}
          delete auths[account.id]
          localStorage.setItem 'twitter-auth', JSON.stringify(auths)
        false
      else
        auths = JSON.parse(localStorage.getItem 'twitter-auth') || {}
        auths[account.id] = account
        auths[account.id].accessToken = accessToken
        auths[account.id].accessTokenSecret = accessTokenSecret
        localStorage.setItem 'twitter-auth', JSON.stringify(auths)

        _cache[account.id] = account

        @subject.onNext
          client: client
          account: account
        true

  constructor: ->
    @subject = new Rx.Subject()
    @observable = @subject.publish()
    @observable.connect()

  get: (id) ->
    if _cache[id]
      auth = _cache[id]
      @subject.onNext
        client: _createClient auth.accessToken, auth.accessTokenSecret
        account: auth
    else
      auths = localStorage.getItem 'twitter-auth'
      if auths[id]
        auth = auths[id]
        client = _createClient auth.accessToken, auth.accessTokenSecret
        _verifyCredential.call @, id, client, auth.accessToken, auth.accessTokenSecret
      else
        @newAuth.call @

  connect: ->
    console.log 'connect'
    authsJson = localStorage.getItem 'twitter-auth'
    if authsJson
      auths = JSON.parse authsJson
      for id, auth of auths
        client = _createClient auth.accessToken, auth.accessTokenSecret
        _verifyCredential.call @, id, client, auth.accessToken, auth.accessTokenSecret

  newAuth: ->
    nodeTwitterApi = new NodeTwitterApi
      callback: 'http://example.com',
      consumerKey: _consumerKey,
      consumerSecret: _consumerSecret,
    nodeTwitterApi.getRequestToken (err, requestToken, requestTokenSecret) =>
      url = nodeTwitterApi.getAuthUrl(requestToken)
      if err
        console.error err
        console.dir err
        return
      authWindow = new BrowserWindow {width: 800, height: 600}
      authWindow.webContents.session.clearStorageData {storages: ['cookies']}, =>

      authWindow.webContents.on 'will-navigate', (event, url) =>
        event.preventDefault()
        if matched = url.match(/\?oauth_token=([^&]*)&oauth_verifier=([^&]*)/)
          nodeTwitterApi.getAccessToken requestToken, requestTokenSecret, matched[2], (error, accessToken, accessTokenSecret) =>
            authWindow.close()
            unless error
              client = _createClient accessToken, accessTokenSecret
              _verifyCredential.call @, null, client, accessToken, accessTokenSecret
        else
          authWindow.close()

      authWindow.on 'closed', ->
        # noop

      authWindow.loadUrl(url)

module.exports = TwitterAuthentication
