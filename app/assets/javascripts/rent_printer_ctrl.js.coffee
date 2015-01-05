rentalApp = angular.module("rentalApp", ['ui.bootstrap'])

angular.module('rentalApp.controllers', []);
angular.module('rentalApp.directives', []);

rentalApp.controller "RentPrinterCtrl", ['$scope', '$http', '$timeout', ($scope, $http, $timeout) ->
  $scope.startDate = null
  $scope.rentalDays = null
  $scope.showStartDate = false
  $scope.dateError = null
  $scope.datesOk = false

  $scope.paymentError = null
  $scope.submitting = false

  $scope.datesChanged = ->
    $scope.dateError = null
    $scope.datesOk = false
    $scope.suggestedDates = null
    return unless $scope.startDate && $scope.rentalDays

    now = new Date()
    if($scope.startDate < now)
      $scope.dateError = "Date must be in the future"
    else
      $scope.checkDates($scope.startDate, $scope.rentalDays)    

  $scope.checkDates = (startDate, rentalDays) ->
    $http.get("/rentals/validate_dates?start_date=" + startDate + "&duration=" + rentalDays).success( (data) ->
      $scope.datesOk = data.available
      
      if $scope.datesOk
        $scope.getQuote($scope.rentalDays, $scope.shipping)
      else
        $scope.dateError = "Ack! This printer is not available for those dates. Try these instead:"
        $scope.suggestedDates = data.windows

    )    

  $scope.rent = ->
    $scope.paymentError = null
    if($scope.validateFields() && $scope.quote)
      $scope.submitting = true
      $scope.stripeCreateToken()      

  $scope.stripeCreateToken = ->
    $scope.submitting = true
    Stripe.setPublishableKey('pk_test_lHvqaoJXXkyU2QpUHzsoNtsH');

    Stripe.card.createToken({
      number: $scope.cardNumber,
      cvc: $scope.cardCVC,
      exp_month: $scope.cardMonth,
      exp_year: $scope.cardYear
    }, $scope.stripeResponseHandler);

  $scope.stripeResponseHandler = (status, response) ->  
    if response.error
      $timeout( ->
        $scope.submitting = false
        $scope.paymentError = response.error.message
      )
    else
      token = response.id
      $scope.requestRental(token)

    return

  $scope.requestRental = (stripeToken) ->
    $http.post("/rentals/rent",
      {
        start_date: $scope.startDate,
        duration: $scope.rentalDays,
        shipping: $scope.shipping,
        name: $scope.name,
        email: $scope.email,
        phone: $scope.phone,
        address_line_1: $scope.addressLine1,
        address_line_2: $scope.addressLine2,
        zipcode: $scope.zipcode,
        stripe_card_token: stripeToken
      }
    ).success(->
      window.location = "/rentals/success"
    ).error( (data) ->
      $scope.paymentError = data.errors
      $scope.submitting = false
    )


  $scope.getQuote = (duration, shipping) ->
    return unless duration && shipping
    
    url = "/rentals/quote?duration=" + duration + "&shipping=" + shipping
    $scope.quote = null
    $http.get(url).success( (data) ->
      $scope.quote = data
    )

  $scope.validateFields = ->
    $scope.missingFields = null
    errors = []

    errors.push("Rental Dates") unless $scope.datesOk
    errors.push("Name") unless $scope.name
    errors.push("Phone") unless $scope.phone
    errors.push("Email") unless $scope.email
    errors.push("Address") unless $scope.addressLine1
    errors.push("Zipcode") unless $scope.zipcode
    errors.push("Card Number") unless $scope.cardNumber
    errors.push("Card CVC") unless $scope.cardCVC
    errors.push("Card Month") unless $scope.cardMonth
    errors.push("Card Year") unless $scope.cardYear
    $scope.missingFields = errors.join(", ") if errors.length > 0

    errors.length == 0

  $scope.openStartDate = (event) -> 
    event.preventDefault()
    event.stopPropagation()
    $scope.showStartDate = true;

]