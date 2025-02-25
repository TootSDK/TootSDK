import XCTest

@testable import TootSDK

final class InstanceTests: XCTestCase {
    func testFriendicaNoContact() throws {
        // arrange
        let json = localContent("instance_friendica_nocontact")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(InstanceV1.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertNil(result.contactAccount)
        XCTAssertEqual(result.languages, ["fr"])
        XCTAssertEqual(result.version, "2.8.0 (compatible; Friendica 2023.05)")
        XCTAssertEqual(result.uri, "social.thisworksonmycomputer.local")
        XCTAssertEqual(result.title, "Social")
        XCTAssertEqual(result.invitesEnabled, false)
        XCTAssertEqual(result.registrations, true)
    }

    func testPixelfed12CountsAreStringsWeHandleGracefully() throws {
        // arrange
        let json = localContent("instance_pixelfed")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(InstanceV1.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.languages, ["en"])
        XCTAssertEqual(result.version, "3.5.3 (compatible; Pixelfed 0.12.3)")
        XCTAssertEqual(result.uri, "pixelfed.social")
        XCTAssertEqual(result.title, "pixelfed")
        XCTAssertEqual(result.registrations, true)
        XCTAssertEqual(result.stats.domainCount, 26576)
        XCTAssertEqual(result.stats.userCount, 119267)
        XCTAssertEqual(result.stats.postCount, 29_662_653)
    }

    func testMastodonV2() throws {
        // arrange
        let json = localContent("instancev2_mastodon")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(InstanceV2.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.languages, ["en"])
        XCTAssertEqual(result.version, "4.3.0+pr-32577-ba659d5")
        XCTAssertEqual(result.domain, "mastodon.social")
        XCTAssertEqual(result.title, "Mastodon")
        XCTAssertEqual(result.sourceURL, "https://github.com/mastodon/mastodon")
        XCTAssertEqual(result.registrations.enabled, true)
        XCTAssertEqual(result.usage?.users.activeMonth, 234394)
        XCTAssertEqual(result.configuration?.accounts?.maxFeaturedTags, 10)
        XCTAssertEqual(result.configuration?.accounts?.maxPinnedPosts, 5)
        XCTAssertEqual(result.icon?.count, 9)
        XCTAssertEqual(result.thumbnail?.blurhash, "UeKUpFxuo~R%0nW;WCnhF6RjaJt757oJodS$")
        XCTAssertEqual(result.thumbnail?.versions?.at2x, "https://files.mastodon.social/site_uploads/files/000/000/001/@2x/57c12f441d083cde.png")
        XCTAssertEqual(result.apiVersions?.mastodon, 2)
        XCTAssertEqual(
            result.configuration?.vapid?.publicKey, "BCk-QqERU0q-CfYZjcuB6lnyyOYfJ2AifKqfeGIm7Z-HiTU5T9eTG5GxVA0_OH5mMlI4UkkDTpaZwozy0TzdZ2M=")
        XCTAssertEqual(result.configuration?.translation?.enabled, true)
    }

    func testFirefishV2() throws {
        // arrange
        let json = localContent("instancev2_firefish")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(InstanceV2.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.languages, [])
        XCTAssertEqual(result.version, "4.2.8 (compatible; Firefish 20240909)")
        XCTAssertEqual(result.domain, "firefish.ranranhome.info")
        XCTAssertEqual(result.title, "FireFish by ranranhome.info（登録開放中）")
        XCTAssertEqual(result.sourceURL, "https://firefish.dev/firefish/firefish")
        XCTAssertEqual(result.registrations.enabled, true)
        XCTAssertEqual(result.usage?.users.activeMonth, 8432)
        XCTAssertEqual(result.configuration?.accounts?.maxFeaturedTags, 20)
        XCTAssertEqual(result.configuration?.accounts?.maxPinnedPosts, nil)
        XCTAssertEqual(result.icon, nil)
        XCTAssertEqual(result.thumbnail?.url, "/static-assets/transparent.png")
        XCTAssertEqual(result.thumbnail?.blurhash, nil)
        XCTAssertEqual(result.thumbnail?.versions, nil)
        XCTAssertEqual(result.apiVersions, nil)
        XCTAssertEqual(
            result.configuration?.vapid?.publicKey, "BP3AruciFygq1IryWRkxbDeGeI-2ClLfHE0mPFtzgVcCNTfmLjPzCl2s28RPM8C0DWE-Rafhs8alu4Zp3fjUTr0")
        XCTAssertEqual(result.configuration?.translation?.enabled, false)
    }

    func testFriendicaV2() throws {
        // arrange
        let json = localContent("instancev2_friendica")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(InstanceV2.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.languages, ["en"])
        XCTAssertEqual(result.version, "2.8.0 (compatible; Friendica 2024.08)")
        XCTAssertEqual(result.domain, "friendica.me")
        XCTAssertEqual(result.title, "Friendica.me")
        XCTAssertEqual(result.sourceURL, "https://git.friendi.ca/friendica/friendica")
        XCTAssertEqual(result.registrations.enabled, false)
        XCTAssertEqual(result.usage?.users.activeMonth, 19)
        XCTAssertEqual(result.configuration?.accounts?.maxFeaturedTags, 0)
        XCTAssertEqual(result.configuration?.accounts?.maxPinnedPosts, nil)
        XCTAssertEqual(result.icon, nil)
        XCTAssertEqual(result.thumbnail?.url, "https://friendica.me/images/friendica-banner.jpg")
        XCTAssertEqual(result.thumbnail?.blurhash, nil)
        XCTAssertEqual(result.thumbnail?.versions, nil)
        XCTAssertEqual(result.apiVersions, nil)
        XCTAssertEqual(
            result.configuration?.vapid, nil)
        XCTAssertEqual(result.configuration?.translation, nil)
    }

    func testGoToSocialV2() throws {
        // arrange
        let json = localContent("instancev2_gotosocial")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(InstanceV2.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.languages, [])
        XCTAssertEqual(result.version, "3.3.0")
        XCTAssertEqual(result.domain, "social.browser.org")
        XCTAssertEqual(result.title, "social.browser.org")
        XCTAssertEqual(result.sourceURL, "https://github.com/superseriousbusiness/gotosocial")
        XCTAssertEqual(result.registrations.enabled, true)
        XCTAssertEqual(result.usage?.users.activeMonth, 0)
        XCTAssertEqual(result.configuration?.accounts?.maxFeaturedTags, 10)
        XCTAssertEqual(result.configuration?.accounts?.maxPinnedPosts, nil)
        XCTAssertEqual(result.icon, nil)
        XCTAssertEqual(
            result.thumbnail?.url,
            "https://social.browser.org/fileserver/01D2P8NTZQKG0EXX2MVKSNB2P8/attachment/original/01HPH8KPPDMSEWF6BDJ12XK1Y1.jpg")
        XCTAssertEqual(result.thumbnail?.blurhash, "LEDSnqt8A5bf-Wj[JBWXEDfl$vf6")
        XCTAssertEqual(result.thumbnail?.versions, nil)
        XCTAssertEqual(result.apiVersions, nil)
        XCTAssertEqual(
            result.configuration?.vapid, nil)
        XCTAssertEqual(result.configuration?.translation?.enabled, false)
    }

    func testPixelfedV2() throws {
        // arrange
        let json = localContent("instancev2_pixelfed")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(InstanceV2.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.languages, ["en"])
        XCTAssertEqual(result.version, "3.5.3 (compatible; Pixelfed 0.12.3)")
        XCTAssertEqual(result.domain, "pixelfed.social")
        XCTAssertEqual(result.title, "pixelfed")
        XCTAssertEqual(result.sourceURL, "https://github.com/pixelfed/pixelfed")
        XCTAssertEqual(result.registrations.enabled, false)
        XCTAssertEqual(result.usage?.users.activeMonth, 8179)
        XCTAssertEqual(result.configuration?.accounts?.maxFeaturedTags, 0)
        XCTAssertEqual(result.configuration?.accounts?.maxPinnedPosts, nil)
        XCTAssertEqual(result.icon, nil)
        XCTAssertEqual(result.thumbnail?.url, "https://pixelfed.social/storage/headers/Hb2Qs2gfWofB4kEmSRArGqfr0h3DeBgrjLcwZ23r.jpg")
        XCTAssertEqual(result.thumbnail?.blurhash, "UzJR]l{wHZRjM}R%XRkCH?X9xaWEjZj]kAjt")
        XCTAssertEqual(result.thumbnail?.versions?.at2x, "https://pixelfed.social/storage/headers/Hb2Qs2gfWofB4kEmSRArGqfr0h3DeBgrjLcwZ23r.jpg")
        XCTAssertEqual(result.apiVersions, nil)
        XCTAssertEqual(
            result.configuration?.vapid?.publicKey, nil)
        XCTAssertEqual(result.configuration?.translation?.enabled, false)
    }

    func testPleromaV2() throws {
        // arrange
        let json = localContent("instancev2_pleroma")
        let decoder = TootDecoder()

        // act
        let result = try decoder.decode(InstanceV2.self, from: json)

        // assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result.languages, ["en"])
        XCTAssertEqual(result.version, "2.7.2 (compatible; Pleroma 2.7.0-70-g36d469cf)")
        XCTAssertEqual(result.domain, "fgc.network")
        XCTAssertEqual(result.title, "FGC.Network")
        XCTAssertEqual(result.sourceURL, "https://git.pleroma.social/pleroma/pleroma")
        XCTAssertEqual(result.registrations.enabled, true)
        XCTAssertEqual(result.usage?.users.activeMonth, 288)
        XCTAssertEqual(result.configuration?.accounts?.maxFeaturedTags, 0)
        XCTAssertEqual(result.configuration?.accounts?.maxPinnedPosts, 3)
        XCTAssertEqual(result.icon, nil)
        XCTAssertEqual(
            result.thumbnail?.url, "https://s3.wasabisys.com/fgc-network-media/6882de6edaf23744e43e1fd2cd91338a7af0aedca6797b4bf3b70123919ef234.png")
        XCTAssertEqual(result.thumbnail?.blurhash, nil)
        XCTAssertEqual(result.thumbnail?.versions, nil)
        XCTAssertEqual(result.apiVersions, nil)
        XCTAssertEqual(
            result.configuration?.vapid?.publicKey, "BFMwLYtsJ1yccxjC4bhxGfV0SQMH-fcrmeQF7p0CUw16C9W6M6Xe3xLiU_bLwA5OKHBUhG9GluqPUfsLMbj74l8")
        XCTAssertEqual(result.configuration?.translation, nil)
    }

    func testMissingThumbnailUrl() throws {
        let json = localContent("instancev2_missing_thumbnail_url")
        let decoder = TootDecoder()
        let result = try decoder.decode(InstanceV2.self, from: json)
        XCTAssertEqual(result.thumbnail, nil)
    }
}
