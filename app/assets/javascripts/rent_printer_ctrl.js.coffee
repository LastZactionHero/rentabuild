rentalApp = angular.module("rentalApp", ['ui.bootstrap'])

angular.module('rentalApp.controllers', []);
angular.module('rentalApp.directives', []);

rentalApp.controller "RentPrinterCtrl", ['$scope', '$http', '$timeout', '$location', ($scope, $http, $timeout, $location) ->
  $scope.steps = [
    "get_started",
    "time_duration",
    "shipping",
    "checkout",
  ]
  $scope.currentStepId = 0


  $scope.currentStep = ->
    $scope.steps[$scope.currentStepId]

  $scope.nextStep = ->
    valid = false
    $scope.missingShippingFields = null

    step = $scope.currentStep()
    if step == "get_started"
      $scope.postSignup()
      valid = $scope.validateGettingStarted()
    else if step == "time_duration"
      valid = $scope.validateTimeDuration()
    else if step == "shipping"
      valid = $scope.validateShipping()

    if valid
      $scope.currentStepId += 1
      mixpanel.track($scope.currentStep());

  $scope.learnMore = ->
    $scope.postSignup()
    window.location = "/how_it_works"

  $scope.prevStep = ->
    $scope.currentStepId -= 1

  $scope.firstStep = ->
    $scope.currentStepId == 0

  $scope.lastStep = ->
    $scope.currentStepId == ($scope.steps.length - 1)

  $scope.validateGettingStarted = ->
    true

  $scope.validateTimeDuration = ->
    $scope.dateError = "You must select rental dates." unless $scope.datesOk
    $scope.datesOk

  $scope.validateShipping = ->
    $scope.missingFields = null
    errors = []

    errors.push("Name") unless $scope.name
    errors.push("Phone") unless $scope.phone
    errors.push("Email") unless $scope.email
    errors.push("Address") unless $scope.addressLine1
    errors.push("Zipcode") unless $scope.zipcode
    errors.push("Shipping") unless $scope.shipping
    $scope.missingShippingFields = errors.join(", ") if errors.length > 0
    errors.length == 0


  $scope.startDate = null
  $scope.rentalDays = null
  $scope.printerId = 2
  $scope.showStartDate = false
  $scope.dateError = null
  $scope.datesOk = false

  $scope.paymentError = null
  $scope.submitting = false
  $scope.termsOfService = false

  $scope.requestedModel = $location.search()['model'];
  $scope.email = $location.search()['email'];
  $scope.zipcode = $location.search()['zipcode'];

  $scope.printerPrices = null

  mixpanel.track("View Rental Page", {
    "model": $scope.requestedModel
  });

  $scope.printerChanged = ->
    $scope.datesChanged()
    $scope.fetchPrinterPrices()

  $scope.fetchPrinterPrices = ->
    $scope.printerPrices = null
    $http.get("/printers/" + $scope.printerId + "/prices").success( (data) ->
      $scope.printerPrices = []
      angular.forEach(data, (price, duration) ->
        $scope.printerPrices.push(
          {
            duration: duration,
            price: price
          }
        )
      )
      $scope.rentalDays = $scope.printerPrices[0].duration
    )

  $scope.rentalDaysChanged = (duration) ->
    $scope.rentalDays = duration
    $scope.datesChanged()

  $scope.datesChanged = ->
    $scope.dateError = null
    $scope.datesOk = false
    $scope.suggestedDates = null
    return unless $scope.startDate && $scope.rentalDays

    mixpanel.track("Dates Changed", {
      "start_date": $scope.start_date,
      "duration": $scope.rentalDays
      });

    now = new Date()
    if($scope.startDate < now)
      $scope.dateError = "Date must be in the future"
    else
      $scope.checkDates($scope.startDate, $scope.rentalDays)

  $scope.checkDates = (startDate, rentalDays) ->
    url = "/rentals/validate_dates?start_date=" + startDate + "&duration=" + rentalDays
    url += "&printer_id=" + $scope.printerId
    $http.get(url).success( (data) ->
      $scope.datesOk = data.available

      if $scope.datesOk
        $scope.getQuote($scope.rentalDays, $scope.shipping, $scope.promoCode)
      else
        $scope.dateError = "Ack! This printer is not available for those dates. Here are some other dates and printers that are available:"
        $scope.suggestedDates = data.windows

    )

  $scope.rent = ->
    $scope.paymentError = null
    unless $scope.termsOfService
      $scope.paymentError = "You must agree to the terms of service."
      return

    if($scope.validateFields() && $scope.quote)
      $scope.submitting = true
      $scope.stripeCreateToken()

  $scope.stripeCreateToken = ->
    $scope.submitting = true

    Stripe.setPublishableKey(stripePublicToken);

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
    mixpanel.track("Rented");

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
        stripe_card_token: stripeToken,
        printer_id: $scope.printerId
      }
    ).success(->
      window.location = "/rentals/success"
    ).error( (data) ->
      $scope.paymentError = data.errors
      $scope.submitting = false
    )


  $scope.getQuote = (duration, shipping, promoCode) ->
    return unless duration && shipping

    url = "/rentals/quote?duration=" + duration + "&shipping=" + shipping
    url += "&printer_id=" + $scope.printerId
    url += "&promo_code=" + promoCode if promoCode

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

  $scope.postSignup = ->
    mixpanel.track("Posted Signup", {
      "email": $scope.email,
    });

    $http.post(
      "/landing_page_signups",
      {
        email: $scope.email,
        zipcode: $scope.zipcode,
      }
    )

  $scope.promoCode = null

  $scope.applyPromoCode = ->
    $scope.getQuote($scope.rentalDays, $scope.shipping, $scope.promoCode)

  $scope.fetchPrinterPrices()
]
