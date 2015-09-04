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

Flow = require './flow.coffee'

class PaneViewModel
  constructor: (flowConfig) ->
    @title = wx.property ''
    @items = wx.list()
    @flow = new Flow(flowConfig)
    @top = wx.list()

    @flow.observable.subscribe (packet) =>
      # console.dir packet
      switch packet.type
        when 'clear'
          @items.clear()

        when 'top'
          @top.clear()
          @top.push packet.viewModel

        when 'title'
          @title packet.title

        when 'item'
          if packet.newer
            @items.insert 0, packet.item
          else
            @items.push packet.item

    @flow.connect()

module.exports = PaneViewModel
