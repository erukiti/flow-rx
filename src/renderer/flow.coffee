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

module.exports = Flow
