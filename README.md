# TillhubPointOfSaleSDK-iOS

[![Build Status](https://travis-ci.com/tillhub/TillhubPointOfSaleSDK-iOS.svg?token=9SwRqYJdTR5WxEaV1u5b&branch=master)](https://travis-ci.com/tillhub/TillhubPointOfSaleSDK-iOS)
[![Version](https://img.shields.io/cocoapods/v/TillhubPointOfSaleSDK.svg)](http://cocoadocs.org/docsets/TillhubPointOfSaleSDK)
[![License](https://img.shields.io/cocoapods/l/TillhubPointOfSaleSDK.svg)](http://cocoadocs.org/docsets/TillhubPointOfSaleSDK)
[![Platform](https://img.shields.io/cocoapods/p/TillhubPointOfSaleSDK.svg)](http://cocoadocs.org/docsets/TillhubPointOfSaleSDK)
[![Swift Version](https://img.shields.io/badge/Swift-5.x-F16D39.svg?style=flat)](https://developer.apple.com/swift)



Use Tillhub to create sales and process payments

## Requirements
* Contact Tillhub via engineering@tillhub.de for your application to be registered
* iOS 10 or later
* Xcode 10.2 or later
* Swift 5.x

## Getting started

### Add the SDK to your project

#### [CocoaPods](https://cocoapods.org)
```
platform :ios, '10.0'
pod 'TillhubPointOfSaleSDK'
```

Be sure to call `pod update` and use `pod install --repo-update` to ensure you have the most recent version of the SDK installed.


-------------------------------

### Update your Info.plist

To get started with the Tillhub Point of Sale SDK, you'll need to configure your `Info.plist` file with a few changes.

First, navigate to your project's settings in Xcode and click the "Info" tab. Under `Custom iOS Target Properties`:
1. Add a new entry with key `LSApplicationQueriesSchemes`.
2. Set the "Type" to `Array`.
3. Add the value `tillhub` to the array.

Next, create a [URL scheme](https://developer.apple.com/library/content/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html#//apple_ref/doc/uid/TP40007072-CH6-SW1) so that Tillhub Point of Sale can re-open your app after a customer finishes a transaction. If your app already has a URL scheme, you can use that.

Finally, open the "URL Types" section and click the "+" to add a new URL type.
Set the values to the following:

Property    | Value
----------- | -----------------
Identifier  | TillhubPointOfSaleSDK
URL Schemes | *Your URL Scheme*
Role        | Editor

-------------------------------


### Register your app with Tillhub

Contact Tillhub via engineering@tillhub.de for your application to be registered. 
Thus the Tillhub application can call back your application with a proper response containing all relevant results.


### Example project

The example project illustrates the most common use cases.
* account: tpos@tillhub.de
* account-ID: `567272bb-8c85-4041-8682-17398be94eb1`

Please contact Tillhub to help you set up another test account or request a password for tpos@tillhub.de.

-------------------------------

### Swift
**Import Declaration:** `import TillhubPointOfSaleSDK`

**- create a TPOSRequest with complete cart details:**

```swift

// common header
let header = TPOSRequestHeader(clientID: "Your client's Tillhub account ID",
                               actionPath: TPOSRequestActionPath.checkout,
                               payloadType: TPOSRequestPayloadType.cart,
                               callbackUrlScheme: "Your Url scheme",
                               autoReturn: true, // Tillhub will automatically return to your application
                               comment: "Testing a checkout with cart details")

// minimal cart item example
let cartItem1 = try TPOSCartItem(productId: "A Tillhub product ID",
                                 currency: "EUR",
                                 pricePerUnit: 99.95,
                                 vatRate: 0.19)

// complex cart item example
let discount1 = try TPOSCartItemDiscount(type: TPOSCartItemDiscountType.relative,
                                        value: 0.15,
                                        comment: "A 15% discount.")
                                        
let discount2 = try TPOSCartItemDiscount(type: TPOSCartItemDiscountType.absolute,
                                        value: 1.00,
                                        comment: "A 1€ discount.") 
                                                
let cartItem2 = try TPOSCartItem(type: TPOSCartItemType.item,
                                 quantity: 2.0,
                                 productId: "A Tillhub product ID",
                                 currency: "EUR",
                                 pricePerUnit: 99.95,
                                 vatRate: 0.19,
                                 title: "Another test product",
                                 comment: "Yet another fancy product",
                                 salesPerson: TPOSStaff(name: "Hubert Cumberdale", customId: "0089"),
                                 discounts: [discount1, discount2])
        
// set up the cart
let paymentIntent = TPOSPaymentIntent(allowedTypes: [TKPOSPaymentType.cash],
                                      automaticType: TKPOSPaymentAutomaticType.automaticCash)

let cart = try TPOSCart(taxType: TPOSTaxType.inclusive,
                        items: [cartItem1, cartItem2],
                        paymentIntent: paymentIntent,
                        customId: "My custom reference",
                        title: "My test cart's title",
                        comment: "My test cart's comment",
                        customer: TPOSCustomer(name: "Marjory Stewart Baxter", customId: "000432001"),
                        cashier: TPOSStaff(name: "Jeremy Fisher", customId: "c_sdj_234"))
                        
// create the request
let cartRequest = TPOSRequest(header: header, payload: cart)

// perform request
TPOS.perform(request: cartRequest) { (error) in
    if let error = error { 
    	print("An error occured: \(error.localizedDescription)") 
    }
	...
}
```


**- create a TPOSRequest with reference to an existing cart:**
```swift

// common header
let header = TPOSRequestHeader(clientID: "Your client's Tillhub account ID",
                               actionPath: TPOSRequestActionPath.load,
                               payloadType: TPOSRequestPayloadType.cartReference,
                               callbackUrlScheme: "Your Url scheme",
                               autoReturn: true, // Tillhub will automatically return to your application
                               comment: "Testing a checkout with a cart reference")

        
// set up cart reference
let cartReference = try TPOSCartReference(cartId: "A Tillhub cart ID")
                        
// create the request
let cartReferenceRequest = TPOSRequest(header: header, payload: cartReference)

// perform request
TPOS.perform(request: cartReferenceRequest) { (error) in
    if let error = error { 
    	print("An error occured: \(error.localizedDescription)") 
    }
	...
}
```

**- parse a response from Tillhub via the UIApplication delegate method:**
```swift

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
	let response = try TPOSResponse(url: url)
	switch response.header.status {
	case .success:
		print("success, response: \(response)")
	case .failure:
		print("failure, error: \(response.header.localizedErrorDescription ?? "- no reason given -")")
	}
}

```

**- resonse JSON data example:**
```json
{
  "payload": {
    "clientTransactionId": "C4C3B14F-413B-4824-986C-23C7868B7B79",
    "summary": {
      "amountTotalNet": 5.99,
      "discountAmountTotal": 1.87,
      "subTotal": 8.67,
      "taxAmountTotal": 0.81,
      "changeAmountTotal": 3.2,
      "tipAmountTotal": 0,
      "paymentAmountTotal": 10,
      "currency": "EUR",
      "amountTotalGross": 6.8
    },
    "items": [
      {
        "quantity": 1,
        "pricePerUnit": 2.89,
        "productId": "84f82be1-29f7-4372-9f58-944966743991",
        "title": "Chio Chips Salt & Vinegar 175g",
        "vatRate": 0.07,
        "discounts": [],
        "type": "item",
        "currency": "EUR",
        "salesPerson": {
          "customId": "0000"
        }
      },
      {
        "quantity": 2,
        "pricePerUnit": 2.89,
        "productId": "9cf299ac-6ac3-4246-bf17-24e7f7812632",
        "title": "Test product",
        "vatRate": 0.19,
        "discounts": [
          {
            "type": "relative",
            "value": 0.15
          },
          {
            "type": "absolute",
            "value": 1
          }
        ],
        "type": "item",
        "currency": "EUR",
        "comment": "Palmolive Flüssigseife Milch & Honig 300ml",
        "salesPerson": {
          "customId": "0000"
        }
      }
    ],
    "payments": [
      {
        "currency": "EUR",
        "amountTip": 0,
        "type": "cash",
        "amountTotal": 10
      }
    ],
    "cashier": {
      "customId": "0000"
    },
    "transactionId": "b0773ea9-a50d-4435-85fa-87003e57ed8d"
  },
  "header": {
    "status": "success",
    "callerDisplayName": "tillhub",
    "requestActionPath": "checkout",
    "sdkVersion": "0.0.3",
    "requestId": "4080485E-7515-4246-B048-4684543396F0",
    "requestPayloadType": "cart",
    "urlScheme": "TillhubPointOfSaleSDKExample"
  }
}
```

## Support
If you are having trouble with using this SDK in your project, please create a question on [Stack Overflow](https://stackoverflow.com/questions/tagged/tillhub-sdk) with the `tillhub-sdk` tag. Our team monitors that tag and will be able to help you. If you think there is something wrong with the SDK itself, please create an issue.


## License
Copyright 2019 Tillhub

Licensed under the [MIT License](https://mit-license.org).

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

