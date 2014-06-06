window.app.directive 'game', () ->
  templateUrl: '/game.html'
  replace: true
  restrict: 'ACE'
  scope: 
    finishCallback: "=finishCallback"
    move_handler: "=moveHandler"
  controller: ['$scope', ($scope) ->
    $scope.game = new Game $scope.move_handler, (result) -> 
      $scope.finishCallback(result)

    $scope.grid = for n in [0...Math.pow($scope.game.map.size,2)]
      [Math.floor(n/$scope.game.map.size), n%$scope.game.map.size]

  ]

class Game
  last_id = 0
  constructor: (@move_handler, @finishCallback) ->
    last_id += 1
    @id = last_id
    @map = new Map
    @started_at = new Date()
    @last_move = 0
    @move_handler.promise.then null, null, (evnt) =>
      side = switch evnt.keyCode
        when 38 then "top"
        when 40 then "bottom"
        when 37 then "left"
        when 39 then "right"
      if side && side != @last_move
        @move side
        @last_move = side
  move: (side) ->
    @clearBonus() 
    @merge side
    @addItems()
    if @finishTest()
      @finish()
    else
      @setBonus()
      @getResults()

    return
  merge: (side) ->
    transform = @map.dimension side
    transform = transform.map (row)->
      row = row.compact(true)
      loop
        match = false
        for item, index in row
          next = index + 1
          if item.match row[next]
            item.upgrade()
            row.splice next, 1
            match = true
            break
        break unless match
      row

    @map.reset side, transform
  addItems: ->
    empty_cells = @map.emptyCells()
    times = if empty_cells.length > 1 then 2 else empty_cells.length
    for n in [0...times]
      item_index = Math.floor(empty_cells.length * Math.random())
      cell = (empty_cells.splice item_index, 1)[0]
      item = new Item
      @map.addItem cell[0], cell[1], item

    return
  finishTest: ->
    return false if @map.emptyCells().length > 0
    # merge test
    # a = b
    # ||
    # c    
    for row in [0...(@map.size-1)]
      for column in [0...(@map.size-1)]
        item = @map.cells[row][column]
        if  item.match(@map.cells[row+1][column]) ||
            item.match(@map.cells[row][column+1])
          return false
  
    true
  finish: ->
    console.log "Finish!"
    @move_handler.resolve "finish"
    @finishCallback
      score: @map.score()
      started_at: @started_at
      finished_at: new Date()
  setBonus: ->
  clearBonus: ->
  getResults: ->
    @items = @map.items()
    @score = @map.score()

class Map
  constructor: (@size = 4)->
    @cells = for rows in [0...@size]
      new Array @size
  rows: ->
    @cells
  columns: (reverse = false)->
    Map.columns @cells, @size, reverse
  @columns: (any_matrix, size, rows_reverse = false, columns_reverse = false) ->
    [rows_range, columns_range] = [rows_reverse, columns_reverse].map (reverse) -> 
      if reverse
        [(size-1)..0]
      else
        [0...size]

    for column_index in columns_range
      for row_index in rows_range
        any_matrix[row_index][column_index]
  dimension: (base)->
    switch base
      when "top"      then @columns()
      when "bottom"   then @columns true
      when "left"     then @rows() # Note: here we return current object of map so trasformations are matter
      when "right"
        @rows().map (row)->
          row.reverse()
  emptyCells: ->
    empty_cells = []
    @each (row_index, column_index) =>
      if !@cells[row_index][column_index]
        empty_cells.push [row_index, column_index]

    empty_cells
  each: (cb)->
    for column_index in [0...@size]
      for row_index in [0...@size]
        cb row_index, column_index

    return
  reset: (dimension_base, new_map) ->
    new_map = new_map.map (row)=>
      row.concat new Array(@size - row.length)
    @cells = switch dimension_base
      when "top"      then Map.columns new_map, @size
      when "bottom"   then Map.columns new_map, @size, false, true
      when "left"     then new_map
      when "right"
        new_map.map (row)->
          row.reverse()
    @resetItemIndexes()

    return
  items: ->
    result = []
    @each (row_index, column_index) =>
      item = @cells[row_index][column_index]
      if item
        result.push item
    result
  resetItemIndexes: ->
    @each (row_index, column_index) =>
      item = @cells[row_index][column_index]
      if item
        item.setIndex row_index, column_index

    return
  addItem: (row, column, item) ->
    @cells[row][column] = item
    item.setIndex row, column
  score: ->
    @items().sum (item)->
      item.grade

class Item
  update_classes = (item)->
    item.classes = ["grade#{item.grade}", "row#{item.row}", "column#{item.column}"]
  constructor: ->
    @grade = 0
  match: (item) ->
    item && item.grade == @grade
  upgrade: ->
    @grade += 1
    update_classes @

  setIndex: (@row, @column) ->
    update_classes @



