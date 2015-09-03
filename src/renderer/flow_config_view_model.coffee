class FlowConfigViewModel
  constructor: (klasses, flowConfig) ->
    @klasses = klasses
    @template = wx.property """
      <div>
        <select data-bind="foreach: items, selectedValue: @selection">
          <option data-bind="value: value, text: key"></option>
        </select>
      </div>
      <div data-bind="foreach: children">
        <div data-bind="html: template">
        </div>
      </div>
      <div>
        <button data-bind="command: complete">完了</button>
      </div>
    """

    @selection = wx.property ''
    @items = wx.list [{key: wx.property '', value: wx.property ''}]

    @subscripten = null

    for key, klass of klasses
      @items.push {
        key: key
        value: key
      }

    @children = wx.list()

    @subject = new Rx.Subject()
    @observable = @subject.publish()
    @observable.connect()

    @config = {}

    @selection.changed.subscribe (value) =>
      if klasses[value]
        @subscripten.dispose() if @subscripten
        configViewModel = klasses[value].configViewModel()
        @subscripten = configViewModel.observable.subscribe (config) =>
          @config = config
          @config['name'] = value
        @children.clear()
        @children.push configViewModel

    @complete = wx.command () =>
      @subject.onNext @config

module.exports = FlowConfigViewModel
