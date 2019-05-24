
import XCTest
@testable import TillhubPointOfSaleSDK_Example

class TPOSExampleTests: XCTestCase {
    
    override func setUp() {}
    
    override func tearDown() {}
    
    func testConverting() {
        let expectation = XCTestExpectation(description: "TPOS request expectation")
        TPOSManager.shared.sendCartRequest(account: "123", actionPath: ActionPath.load) { (result) in
            expectation.fulfill()
        }
    }
}
