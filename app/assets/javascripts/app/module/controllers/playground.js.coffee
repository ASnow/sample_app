window.playgroundCtrl = ['$scope', ($scope) ->
  $scope.in_game = false
  $scope.scores = []
  $scope.startGame = ->
    $scope.in_game = true

  $scope.finishGame = (result)->
    $scope.scores.push result
    $scope.in_game = false
]
