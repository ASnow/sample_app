window.playgroundCtrl = ['$scope', '$document', '$q', ($scope, $document, $q) ->
  $scope.in_game = false
  $scope.scores = []
  $scope.key_handler = null
  $scope.startGame = ->
    $scope.in_game = true
    $scope.key_handler = $q.defer()


  # callback style (can put this in deffer) 
  $scope.finishGame = (result)->
    $scope.scores.push result
    $scope.in_game = false

  $document.bind 'keyup', (evnt) =>
    $scope.key_handler.notify evnt

]
