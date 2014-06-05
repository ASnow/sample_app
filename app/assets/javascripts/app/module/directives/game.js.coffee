window.app.directive 'game', () ->
  templateUrl: '/game.html'
  replace: true
  restrict: 'ACE'
  scope: 
    startCallback: "=onStart"
    finishCallback: "=onFinish"
  controller: ['$scope', ($scope) ->
    $scope.



  ]

class Game
  constructor: ->
    @map = new Map

  move: (side) ->
    @clearBonus()
    @merge side
    @addItems()
    if @finishTest()
      @setBonus()

  merge: (side) ->
    transform = @map.dimension side
    transform = transform.map (row)->
      row = row.compact(true)
      while match
        match = false
        for item, index in row
          next = index + 1
          if item.match row[next]
            item.upgrade()
            row.splice next, 1
            match = true
            break
      row
    @map.reset side, transform

  finishTest: ->
    # a = b
    # ||
    # c    


class Map
  constructor: (@size = 4)->
    @cells = for rows in [0...@size]
      new Array @size
  rows: ->
    @cells
  columns: (reverse = false)->
    rows_range = if reverse
      [(@size-1)..0]
    else
      [0...@size]
    for column_index in [0...@size]
      for row_index in rows_range
        @cells[row_index][column_index]
  dimension: (base)->
    switch base
    case "left"
      @rows()
    case "right"
      @rows().map (row)->
        row.reverse()
    case "top"
      @columns()
    case "buttom"
      @columns true
  emptyCells: ->
    empty_cells = []
    for column_index in [0...@size]
      for row_index in [0...@size]
        if !@cells[row_index][column_index]
          empty_cells.push [row_index, column_index]
    empty_cells
  reset: (dimension_base, new_map) ->



class Item
  constructor: ->
    @grade = 0
  match: (item) ->
    item.grade = @grade
  upgrade: ->
    @grade += 1

