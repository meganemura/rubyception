class App.Routers.Log extends Backbone.Router
  routes:
    '': 'default'
  initialize:->
    socket           = new WebSocket 'ws://localhost:3030/'
    socket.onopen    = @onopen
    socket.onerror   = @onerror
    socket.onclose   = @onclose
    socket.onmessage = @onmessage
    @collection       = new App.Collections.Entries()
    @collection.model = App.Models.Entry
  onopen:        => console.log 'Socket onopen'
  onerror:       => console.log 'Socket onerror'
  onclose:  (msg)=> console.log 'Socket onclose'
  onmessage:(msg)=>
    data = JSON.parse msg.data
    console.log data
    if data.finished
      model = _.last @collection.models
      model.save data
    else
      @collection.add data
  default: ->
    @index()
  hotkeys: ->
    console.log 'HPTKEYS'
    doc = $(document)
    Mousetrap.bind 'down', @collection.selection_down
    Mousetrap.bind 'up', @collection.selection_up
    for i in [0..9]
      Mousetrap.bind String(i), _.bind @store_number_hotkey, @, String(i)
    Mousetrap.bind 'o', @collection.open_selected
      
    Mousetrap.bind 'shift+g', =>
      @go_to_entry_or('bottom')
    Mousetrap.bind 'g g', =>
      @go_to_entry_or('top')
  store_number_hotkey: (i) =>
    @number_hotkey ||= ''
    @number_hotkey += i
    console.log @number_hotkey, i
  go_to_entry_or: (location) =>
    console.log 'CONSUME', @number_hotkey
    if @number_hotkey && @number_hotkey != ''
      if @collection.models[@number_hotkey - 1]
        @collection.select_model @number_hotkey - 1
    else if @collection.models.length > 0
      if location == 'top'
        @collection.select_model 0
      else if location == 'bottom'
        @collection.select_model @collection.models.length - 1
    @number_hotkey = ''
  index: ->
    @hotkeys()
    @partial '.content', 'logs/show',
      collection: @collection
    entry_1 =
      id         : 1
      controller : 'projects'
      action     : 'index'
      path       : '/all_projects'
      method     : 'get'
      format     : 'html'
      duration   : '255'
      start_time : '2012-05-05 15:13:12'
      lines      : [{name:1},{name:2}]
    entry_2 =
      id         : 2
      controller : 'tasks'
      action     : 'show'
      path       : '/tasks/164/show'
      method     : 'get'
      format     : 'json'
      duration   : '1023'
      start_time : '2012-05-05 15:13:12'
      lines      : [{name:1},{name:2}]
    @collection.reset [entry_1,entry_2]
