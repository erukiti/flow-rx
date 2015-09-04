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

TwitterFlow = require './twitter_flow.coffee'
Flow = require './flow.coffee'
PaneViewModel = require './pane_view_model.coffee'

class MainViewModel
  constructor: ->
    @panes = wx.list()

    flowConfigs = localStorage.getItem 'flows'
    if flowConfigs
      for flowConfig in flowConfigs
        @panes.push new PaneViewModel(flowConfig)
    else
      @panes.push new PaneViewModel()

    # wx.messageBus

Flow.register 'twtter', TwitterFlow

mainViewModel = new MainViewModel()
wx.applyBindings(mainViewModel)
