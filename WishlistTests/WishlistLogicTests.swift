import XCTest
@testable import Wishlist

final class WishlistLogicTests: XCTestCase {
    func testParsesGermanAmountWithGroupingAndCurrency() {
        let locale = Locale(identifier: "de_DE")

        XCTAssertEqual(WishlistAmountFormatter.parse("1.234,56 €", locale: locale), 1_234.56)
    }

    func testParsesEnglishAmountWithGrouping() {
        let locale = Locale(identifier: "en_US")

        XCTAssertEqual(WishlistAmountFormatter.parse("1,234.56", locale: locale), 1_234.56)
    }

    func testRejectsInvalidAmount() {
        XCTAssertNil(WishlistAmountFormatter.parse("not a price", locale: Locale(identifier: "en_US")))
    }

    func testFormattedAmountCanBeParsedAgain() {
        let locale = Locale(identifier: "de_DE")
        let formatted = WishlistAmountFormatter.format(1_234.5, locale: locale)

        XCTAssertEqual(WishlistAmountFormatter.parse(formatted, locale: locale), 1_234.5)
    }

    func testWishModelsKeepTheirValues() {
        let short = ShortItems(name: "Book", remark: "Hardcover", link: "https://example.com", price: 24.90)
        let mid = MidItems(name: "Bike", remark: "Blue", link: "https://example.com", price: 799)
        let long = LongItems(name: "Trip", remark: "Japan", link: "https://example.com", price: 2_500)

        XCTAssertEqual(short.name, "Book")
        XCTAssertEqual(mid.remark, "Blue")
        XCTAssertEqual(long.price, 2_500)
    }

    func testSettingsDefaults() {
        let settings = MySettings()

        XCTAssertEqual(settings.themeMode, "system")
        XCTAssertNil(settings.backgroundImageData)
        XCTAssertEqual(settings.backgroundColor, "#FFFFFF")
    }

    func testWishlistShareTextIncludesOnlyNonEmptyLinks() {
        let text = WishlistShareText.make(links: [" https://example.com/one ", "  ", "https://example.com/two"])

        XCTAssertTrue(text.hasPrefix(String(localized: "My Wishlist")))
        XCTAssertTrue(text.hasSuffix("https://example.com/one\n\nhttps://example.com/two"))
    }

    func testSignalShareTextDisablesLinkPreviews() {
        let text = WishlistShareText.withoutLinkPreviews("My Wishlist\n\nhttps://example.com/one\n\nhttps://example.com/two")

        XCTAssertTrue(text.contains("https://\u{200B}example.com/one"))
        XCTAssertTrue(text.contains("https://\u{200B}example.com/two"))
    }
}
