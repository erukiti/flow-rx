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

app = require 'app'
BrowserWindow = require 'browser-window'
Menu = require 'menu'
ipc = require 'ipc'

global.consumerKey = 'e2YhxWSNBSp0FLwvooeJboULL'
global.consumerSecret = '6ra3XCxeCZUSwUXT4DyjsvyBkGIsLittI4zBroQ6eyhB7mf4Kz'

app.on 'window-all-closed', ->
  app.quit()

app.on 'ready', ->
  win = new BrowserWindow {
    width: 800 
    height: 600
    # 'web-preferences': {'web-security': false}
  }
  win.loadUrl "file://#{__dirname}/../renderer/index.html"
  win.on 'closed', ->
    win = null

