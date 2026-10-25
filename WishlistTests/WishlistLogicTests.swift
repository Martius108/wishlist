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
        XCTAssertEqual(WishlistAmountFormatter.parse("499.00", locale: locale), 499.00)
    }

    func testRejectsInvalidAmount() {
        XCTAssertNil(WishlistAmountFormatter.parse("not a price", locale: Locale(identifier: "en_US")))
    }

    func testFormattedAmountCanBeParsedAgain() {
        let locale = Locale(identifier: "de_DE")
        let formatted = WishlistAmountFormatter.format(1_234.5, locale: locale)

        XCTAssertEqual(WishlistAmountFormatter.parse(formatted, locale: locale), 1_234.5)
    }

    func testEnglishCurrencyUsesUSFormatting() {
        XCTAssertEqual(
            WishlistAmountFormatter.currencyString(499, locale: Locale(identifier: "en_US")),
            "$499.00"
        )
    }

    func testWishModelsKeepTheirValues() {
        let listID = UUID()
        let short = ShortItems(name: "Book", remark: "Hardcover", link: "https://example.com", price: 24.90)
        let mid = MidItems(
            name: "Bike",
            remark: "Blue",
            link: "https://example.com",
            price: 799,
            wishlistID: listID
        )
        let long = LongItems(name: "Trip", remark: "Japan", link: "https://example.com", price: 2_500)

        XCTAssertEqual(short.name, "Book")
        XCTAssertEqual(mid.remark, "Blue")
        XCTAssertEqual(mid.wishlistID, listID)
        XCTAssertEqual(long.price, 2_500)
    }

    func testWishlistHasStableIdentifierAndDefaults() {
        let id = UUID()
        let wishlist = WishlistList(id: id, name: "Travel")

        XCTAssertEqual(wishlist.id, id)
        XCTAssertEqual(wishlist.name, "Travel")
        XCTAssertTrue(wishlist.isVisible)
        XCTAssertEqual(wishlist.sortOrder, 0)
        XCTAssertEqual(WishlistList.maximumCount, 4)
    }

    func testFindsOnlyEmptyAssignedLegacyFourthWishlist() {
        let standardLists = [
            WishlistList(name: "Kurzfristig", sortOrder: 0),
            WishlistList(name: "Mittelfristig", sortOrder: 1),
            WishlistList(name: "Langfristig", sortOrder: 2)
        ]
        let placeholder = WishlistList(name: "Wunschliste", sortOrder: 3)
        let wishlists = standardLists + [placeholder]

        XCTAssertEqual(
            WishlistList.legacyPlaceholder(
                in: wishlists,
                occupiedIDs: [],
                hasUnassignedWishes: false
            )?.id,
            placeholder.id
        )
        XCTAssertNil(
            WishlistList.legacyPlaceholder(
                in: wishlists,
                occupiedIDs: [placeholder.id],
                hasUnassignedWishes: false
            )
        )
        XCTAssertNil(
            WishlistList.legacyPlaceholder(
                in: wishlists,
                occupiedIDs: [],
                hasUnassignedWishes: true
            )
        )
    }

    func testSettingsDefaults() {
        let settings = MySettings()

        XCTAssertEqual(settings.themeMode, "system")
        XCTAssertEqual(settings.elementOpacity, 1)
        XCTAssertNil(settings.backgroundImageData)
        XCTAssertEqual(settings.backgroundColor, MySettings.systemBackgroundColor)
    }

    func testOpacityIsClampedToItsValidRange() {
        XCTAssertEqual(MySettings(elementOpacity: -0.2).elementOpacity, 0)
        XCTAssertEqual(MySettings(elementOpacity: 1.2).elementOpacity, 1)
        XCTAssertEqual(MySettings(elementOpacity: 0.42).elementOpacity, 0.42)
    }

    func testApplyingThemeRestoresSystemBackground() {
        let settings = MySettings(
            backgroundImageData: Data([1, 2, 3]),
            backgroundColor: "#123456",
            elementOpacity: 0.42
        )

        settings.applyTheme("dark")

        XCTAssertEqual(settings.themeMode, "dark")
        XCTAssertEqual(settings.elementOpacity, 0.42)
        XCTAssertNil(settings.backgroundImageData)
        XCTAssertEqual(settings.backgroundColor, MySettings.systemBackgroundColor)
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
