rentalApp = angular.module("rentalApp", ['ui.bootstrap'])

angular.module('rentalApp.controllers', []);
angular.module('rentalApp.directives', []);

rentalApp.controller "RentPrinterCtrl", ['$scope', '$http', '$timeout', '$location', ($scope, $http, $timeout, $location) ->
  $scope.startDate = null
  $scope.rentalDays = null
  $scope.showStartDate = false
  $scope.dateError = null
  $scope.datesOk = false

  $scope.paymentError = null
  $scope.submitting = false
  $scope.termsOfService = false

  $scope.requestedModel = $location.search()['model'];
  $scope.email = $location.search()['email'];
  $scope.zipcode = $location.search()['zipcode'];

  mixpanel.track("View Rental Page", {
    "model": $scope.requestedModel
  });

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
    unless $scope.termsOfService
      $scope.paymentError = "You must agree to the terms of service."
      return
    
    if($scope.validateFields() && $scope.quote)
      $scope.submitting = true
      $scope.stripeCreateToken()      

  $scope.stripeCreateToken = ->
    $scope.submitting = true
    Stripe.setPublishableKey('pk_live_JMNFrzKGf9KRDiSOmj3PMo6w');

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


rentalApp.controller "RentalCtrl", ['$scope', '$http', '$location', '$anchorScroll', ($scope, $http, $location, $anchorScroll) ->

  $scope.printers = [
    {
      name: "BQ Witbox",
      build_depth: 210,
      build_height: 200,
      build_width: 297,
      speed: "60 mm/s",
      filament: "PLA",
      price: 1690,
      sd: true,
      usb: true,
      website: "http://www.bqreaders.com/gb/products/witbox.html",
      image: "http://www-cdn.bq.com/img/web/product_images/witbox/gallery/bq-witbox-02.jpg"
    },
    {
      name: "CEL Robux",
      build_depth: 99,
      build_height: 149,
      build_width: 210,
      speed: "30 mm/s - 350 mm/s",
      filament: "PLA",
      price: 1399,
      sd: false,
      usb: true,
      website: "http://www.aniwaa.com/product/cel-robox/",
      image: "http://1-ps.googleusercontent.com/h/www.aniwaa.com/wp-content/uploads/2013/11/xProduct-CEL-Robox.jpg.pagespeed.ic.trKGQ5aNiR.webp"
    },
    {
      name: "Cube 3",
      build_depth: 152,
      build_height: 152,
      build_width: 152,
      speed: "15 mm/s"
      filament: "ABS, PLA",
      price: 1099,
      sd: true,
      usb: true,
      website: "http://cubify.com/en/Cube",
      image: "https://dud5umgikjidx.cloudfront.net/resources/images/dropdown/cube.png"
    },
    {
      name: "Cube Pro",
      build_depth: 285,
      build_height: 285,
      build_width: 285,
      speed: "15 mm/s"
      filament: "ABS, PLA",
      price: 2899,
      sd: true,
      usb: true,
      website: "http://cubify.com/en/CubePro/",
      image: "https://dud5umgikjidx.cloudfront.net/resources/images/dropdown/cubepro.png"
    },    
    {
      name: 'CubePro Duo',
      build_depth: 269,
      build_height: 230,
      build_width: 242,
      speed: '15 mm/s'
      filament: 'ABS, PLA',
      price: 3399.0,
      sd: false,
      usb: true,
      website: 'http://cubify.com/en/CubePro/',
      image: "https://dud5umgikjidx.cloudfront.net/resources/images/dropdown/cubepro.png"
    },

    {
      name: 'CubePro Trio',
      build_depth: 241,
      build_height: 185,
      build_width: 273,
      speed: '15 mm/s'
      filament: 'ABS, PLA',
      price: 4399.0,
      sd: false,
      usb: true,
      website: 'http://cubify.com/en/CubePro/',
      image: "https://dud5umgikjidx.cloudfront.net/resources/images/dropdown/cubepro.png"
    },

    {
      name: 'Makerbot 2X',
      build_depth: 149,
      build_height: 248,
      build_width: 160,
      speed: '30 mm/s - 300 mm/s'
      filament: 'PLA',
      price: 2499.0,
      sd: true,
      usb: true,
      website: 'http://store.makerbot.com/replicator2x',
      image: 'http://static.makerwise.com/static/img/3d-printer/orig/310/makerbot-industries-replicator-2x-08.jpg'
    },

    {
      name: 'Makerbot Replicator 5',
      build_depth: 251,
      build_height: 149,
      build_width: 198,
      speed: '30 mm/s - 300 mm/s'
      filament: 'PLA',
      price: 2899.0,
      sd: false,
      usb: true,
      website: 'https://store.makerbot.com/replicator',
      image: 'http://www.3diot.net/wp-content/uploads/1405471228rep5.jpg'
    },

    {
      name: 'Makerbot Replicator Mini',
      build_depth: 99,
      build_height: 99,
      build_width: 124,
      speed: '30 mm/s - 300 mm/s'
      filament: 'PLA',
      price: 1375,
      sd: false,
      usb: true,
      website: 'http://store.makerbot.com/replicator-mini',
      image: 'http://static.makerwise.com/static/img/3d-printer/orig/630/makerbot-replicator-mini-06.jpg'
    },

    {
      name: 'Makerbot Replicator Z18',
      build_depth: 457,
      build_height: 304,
      build_width: 304,
      speed: '30 mm/s - 300 mm/s'
      filament: 'PLA',
      price: 6499,
      sd: false,
      usb: true,
      website: 'https://store.makerbot.com/replicator-z18',
      image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAZB-Vn1zT1IY1ARmNLCyoWHBUzjDTcE-70ez2D-TSvZMfVDJO'
    },

    {
      name: 'Solidoodle 4',
      build_depth: 203,
      build_height: 203,
      build_width: 203,
      speed: '120 mm/s'
      filament: 'ABS, PLA',
      price: 599.0,
      sd: false,
      usb: true,
      website: 'http://www.solidoodle.com/',
      image: 'http://www.3ders.org/images/solidoodle-4-3d-printer-1.jpg'
    },

    {
      name: 'Solidoodle Press',
      build_depth: 381,
      build_height: 487,
      build_width: 391,
      speed: '120 mm/s'
      filament: 'ABS, PLA',
      price: 499.0,
      sd: false,
      usb: true,
      website: 'http://www.solidoodle.com/press/',
      image: 'http://www.solidoodle.com/image/cache/data/Press_pers-326x326.png'
    },

    {
      name: 'Solidoodle Workbench',
      build_depth: 304,
      build_height: 304,
      build_width: 305,
      speed: '120 mm/s'
      filament: 'ABS, PLA',
      price: 1299.0,
      sd: false,
      usb: true,
      website: 'http://www.solidoodle.com/workbench',
      image: 'http://www.solidoodle.com/image/cache/data/WB_pers%20(1)-326x326.png'
    },

    {
      name: 'Solidoodle Workbench Apprentice',
      build_depth: 203,
      build_height: 152,
      build_width: 152,
      speed: '120 mm/s'
      filament: 'ABS, PLA',
      price: 799.0,
      sd: false,
      usb: true,
      website: 'http://www.solidoodle.com/workbench-apprentice',
      image: 'http://www.solidoodle.com/image/cache/data/SDA_pers-326x326.png'
    },

    {
      name: 'Ultimaker II',
      build_depth: 204,
      build_height: 229.87,
      build_width: 224,
      speed: '30 mm/s - 300 mm/s'
      filament: 'PLA',
      price: 2500.0,
      sd: true,
      usb: true,
      website: 'https://www.ultimaker.com/',
      image: 'https://d274pdkuk9fmjq.cloudfront.net/spree/uploads/81/medium/Stylish-looks.png'
    },

    {
      name: 'Ultimaker Original',
      build_depth: 203,
      build_height: 228,
      build_width: 223,
      speed: '30 mm/s - 300 mm/s'
      filament: 'ABS, PLA',
      price: 1244.0,
      sd: true,
      usb: true,
      website: 'https://www.ultimaker.com/products/ultimaker-original',
      image: 'https://www.ultimaker.com/spree/uploads/54/medium/faq1_(1).jpg'
    },

    {
      name: 'UP! Mini',
      build_depth: 119,
      build_height: 119,
      build_width: 119,
      speed: '30 mm/s'
      filament: 'ABS',
      price: 899.0,
      sd: false,
      usb: false,
      website: 'http://www.pp3dp.com',
      image: 'http://hothardware.com/articleimages/Item1946/small_up-mini-front-open.jpg'
    },

    {
      name: 'UP! Plus 2',
      build_depth: 139,
      build_height: 134,
      build_width: 139,
      speed: '30 mm/s'
      filament: 'ABS, PLA',
      price: 1649.0,
      sd: false,
      usb: false,
      website: 'http://www.pp3dp.com/index.php?page=shop.product_details&flypage=flypage.tpl&product_id=10&category_id=1&option=com_virtuemart&Itemid=37&vmcchk=1&Itemid=37',
      image: 'http://www.dynamism.com/images/gallery/up_plus_2_01.jpg'
    },

    {
      name: 'Wanhao Duplicator 4x',
      build_depth: 144,
      build_height: 144,
      build_width: 224,
      speed: '40 mm/s'
      filament: 'ABS, PLA, PVA',
      price: 1229.0,
      sd: true,
      usb: true,
      website: 'http://wanhaousa.com/',
      image: 'http://i00.i.aliimg.com/wsphoto/v0/1485390874_1/wanhao-3d-printer-new-version-Duplicator-4X-hot-sell-with-2kg-filaments-for-any-color.jpg'
    },

    {
      name: 'XYZPrinting Da Vinci 1.0',
      build_depth: 198,
      build_height: 198,
      build_width: 198,
      speed: '150 mm/sec'
      filament: 'ABS',
      price: 499.0,
      sd: false,
      usb: true,
      website: 'http://us.xyzprinting.com/Product',
      image: 'http://ecx.images-amazon.com/images/I/41z6by2EdyL._SX342_.jpg'
    },

  ]

  $scope.durations = [
    "1 week",
    "3 weeks",
    "1 month",
    "3 months"
  ]

  $scope.printer = $scope.printers[14]
  $scope.duration = $scope.durations[0]
  $scope.email = null
  $scope.zipcode = null

  mixpanel.track("Landing Page Load");

  $scope.rent = ->

    mixpanel.track("Signup", {
      "printer": $scope.printer.name,
      "email": $scope.email,
      "zipcode": $scope.zipcode,
      "duration": $scope.duration
      });

    $http.post(
      "/landing_page_signups",
      {
        email: $scope.email,
        duration: $scope.duration,
        zipcode: $scope.zipcode,
        model_name: $scope.printer.name
      }
    ).success( ->      
      url = "/rentals/new#"
      url += "?model=" + encodeURIComponent($scope.printer.name)

      if $scope.email
        url += "&email=" + encodeURIComponent($scope.email)

      if $scope.zipcode
        url += "&zipcode=" + encodeURIComponent($scope.zipcode)

      window.location = url
    )

  $scope.heroChange = ->
    mixpanel.track("Hero Change", {"printer": $scope.printer.name});
    $location.hash('rental-form')
    $anchorScroll()

]