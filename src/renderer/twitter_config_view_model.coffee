TwitterAuthentication = require './twitter_authentication.coffee'

class TwitterConfigViewModel
  constructor: ->
    @template = wx.property """
      <div>
        <button data-bind="command: newAuth">新しく認証</button>
      </div>
      <select data-bind="foreach: auths, selectedValue: @selection">
        <option data-bind="value: value, text: text"></option>
      </select>
    """

    @auths = wx.list([{text: '選択してください', value: ''}])
    @selection = wx.property ''
    @authMap = {}

    @config = {}

    @authentication = new TwitterAuthentication()
    @authentication.observable.subscribe (packet) =>
      @auths.push {
        text: "#{packet.account.name}@#{packet.account.screen_name}"
        value: packet.account.id
      }
      @authMap[packet.account.id] = packet
    @authentication.connect()

    @newAuth = wx.command =>
      @authentication.newAuth()

    @subject = new Rx.Subject()
    @observable = @subject.publish()
    @observable.connect()

    @selection.changed.subscribe (value) =>
      @client = @authMap[value].client
      @config['id'] = value
      @subject.onNext @config

module.exports = TwitterConfigViewModel
