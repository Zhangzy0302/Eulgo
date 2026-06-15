import Foundation

enum StarterSeedInitialData {
    static func starterSeedInitializeIfNeeded() {
        starterSeedUsersIfNeeded()
        starterSeedVideoPostsIfNeeded()
        starterSeedCommentsIfNeeded()
        starterSeedActivitiesIfNeeded()
        starterSeedChatRoomsIfNeeded()
        starterSeedChatMessagesIfNeeded()
        starterSeedVenuesIfNeeded()
        starterSeedVenueRatingsIfNeeded()
    }

    static func starterSeedResetAndInitialize() {
        TeeBoxUserStore.teeBoxDeleteAllUsers()
        BirdieClipVideoPostStore.birdieClipDeleteAllPosts()
        GreenNoteCommentStore.greenNoteDeleteAllComments()
        MatchDayActivityStore.matchDayDeleteAllActivities()
        ClubPairChatRoomStore.clubPairDeleteAllRooms()
        WhisperLineChatMessageStore.whisperLineDeleteAllMessages()
        LinksMapVenueStore.linksMapDeleteAllVenues()
        ScoreCardVenueRatingStore.scoreCardDeleteAllRatings()

        starterSeedInitializeIfNeeded()
    }

    static func starterSeedDate(
        year starterSeedYear: Int,
        month starterSeedMonth: Int,
        day starterSeedDay: Int,
        hour starterSeedHour: Int = 0,
        minute starterSeedMinute: Int = 0
    ) -> Date {
        var starterSeedComponents = DateComponents()
        starterSeedComponents.calendar = Calendar(identifier: .gregorian)
        starterSeedComponents.timeZone = TimeZone.current
        starterSeedComponents.year = starterSeedYear
        starterSeedComponents.month = starterSeedMonth
        starterSeedComponents.day = starterSeedDay
        starterSeedComponents.hour = starterSeedHour
        starterSeedComponents.minute = starterSeedMinute

        return starterSeedComponents.date ?? Date()
    }
}

private extension StarterSeedInitialData {
    static var starterSeedUsers: [TeeBoxUserModel] {
        [
            TeeBoxUserModel(
                teeBoxUserID: "seed-user-chloe",
                teeBoxEmail: "eulgo@gmail.com",
                teeBoxPassword: "123456",
                teeBoxAvatarAddress: "EULGO_UImg_0",
                teeBoxUsername: "chloe",
                teeBoxBirthdayDate: starterSeedDate(year: 2001, month: 3, day: 12),
                teeBoxLocation: "LA",
                teeBoxGender: "Female",
                teeBoxFollowerIDs: [
                    "seed-user-lucadorotovics",
                    "seed-user-justpresty"
                ],
                teeBoxFollowingIDs: [
                    "seed-user-lucadorotovics",
                    "seed-user-batch"
                ]
            ),
            TeeBoxUserModel(
                teeBoxUserID: "seed-user-lucadorotovics",
                teeBoxEmail: "lucadorotovics@eulgo.local",
                teeBoxPassword: "123456",
                teeBoxAvatarAddress: "EULGO_UImg_1",
                teeBoxUsername: "lucadorotovics",
                teeBoxBirthdayDate: starterSeedDate(year: 1998, month: 7, day: 24),
                teeBoxLocation: "Pebble Beach",
                teeBoxGender: "Male",
                teeBoxFollowerIDs: [
                    "seed-user-chloe"
                ],
                teeBoxFollowingIDs: [
                    "seed-user-chloe"
                ]
            ),
            TeeBoxUserModel(
                teeBoxUserID: "seed-user-justpresty",
                teeBoxEmail: "justpresty@eulgo.local",
                teeBoxPassword: "123456",
                teeBoxAvatarAddress: "EULGO_UImg_2",
                teeBoxUsername: "justpresty",
                teeBoxBirthdayDate: starterSeedDate(year: 2000, month: 11, day: 6),
                teeBoxLocation: "San Diego",
                teeBoxGender: "Female",
                teeBoxFollowingIDs: [
                    "seed-user-chloe"
                ]
            ),
            TeeBoxUserModel(
                teeBoxUserID: "seed-user-batch",
                teeBoxEmail: "batch@eulgo.local",
                teeBoxPassword: "123456",
                teeBoxAvatarAddress: "EULGO_UImg_3",
                teeBoxUsername: "batch",
                teeBoxBirthdayDate: starterSeedDate(year: 1999, month: 5, day: 18),
                teeBoxLocation: "Scottsdale",
                teeBoxGender: "Male",
                teeBoxFollowerIDs: [
                    "seed-user-chloe"
                ]
            ),
            TeeBoxUserModel(
                teeBoxUserID: "seed-user-chordsing",
                teeBoxEmail: "chordsing@eulgo.local",
                teeBoxPassword: "123456",
                teeBoxAvatarAddress: "EULGO_UImg_4",
                teeBoxUsername: "chordsing",
                teeBoxBirthdayDate: starterSeedDate(year: 2002, month: 9, day: 2),
                teeBoxLocation: "Palm Springs",
                teeBoxGender: "Male"
            )
        ]
    }

    static var starterSeedVideoPosts: [BirdieClipVideoPostModel] {
        [
            BirdieClipVideoPostModel(
                birdieClipPostID: "seed-video-post-0",
                birdieClipPublisherID: "seed-user-chloe",
                birdieClipCoverAddress: "EULGO_PV_Cover_0",
                birdieClipVideoAddress: "EULGO_PV_0",
                birdieClipCaptionText: "I feel bad for anyone who has to take me golfing with them 😂",
                birdieClipLikeCount: 141
            ),
            BirdieClipVideoPostModel(
                birdieClipPostID: "seed-video-post-1",
                birdieClipPublisherID: "seed-user-lucadorotovics",
                birdieClipCoverAddress: "EULGO_PV_Cover_1",
                birdieClipVideoAddress: "EULGO_PV_1",
                birdieClipCaptionText: "Totally a joke i’m a great student and he’s a great coach 😙",
                birdieClipLikeCount: 98
            ),
            BirdieClipVideoPostModel(
                birdieClipPostID: "seed-video-post-2",
                birdieClipPublisherID: "seed-user-justpresty",
                birdieClipCoverAddress: "EULGO_PV_Cover_2",
                birdieClipVideoAddress: "EULGO_PV_2",
                birdieClipCaptionText: "The perfect drill to dial in your backswing. 90° wrist hinge, then cover your hands with the clubhead with the leading edge parallel to your spine angle.",
                birdieClipLikeCount: 126
            ),
            BirdieClipVideoPostModel(
                birdieClipPostID: "seed-video-post-3",
                birdieClipPublisherID: "seed-user-batch",
                birdieClipCoverAddress: "EULGO_PV_Cover_3",
                birdieClipVideoAddress: "EULGO_PV_3",
                birdieClipCaptionText: "TEAM NAVY reporting for duty ⚓️",
                birdieClipLikeCount: 87
            ),
            BirdieClipVideoPostModel(
                birdieClipPostID: "seed-video-post-4",
                birdieClipPublisherID: "seed-user-chordsing",
                birdieClipCoverAddress: "EULGO_PV_Cover_4",
                birdieClipVideoAddress: "EULGO_PV_4",
                birdieClipCaptionText: "I played over 36 holes of golf today. I love golf.",
                birdieClipLikeCount: 164
            )
        ]
    }

    static var starterSeedComments: [GreenNoteCommentModel] {
        [
            GreenNoteCommentModel(
                greenNoteCommentID: "seed-comment-0",
                greenNoteVideoID: "seed-video-post-0",
                greenNotePublisherID: "seed-user-lucadorotovics",
                greenNoteContentText: "That first swing had so much personality.",
                greenNoteCreatedAt: starterSeedDate(year: 2026, month: 6, day: 1, hour: 9, minute: 12)
            ),
            GreenNoteCommentModel(
                greenNoteCommentID: "seed-comment-1",
                greenNoteVideoID: "seed-video-post-0",
                greenNotePublisherID: "seed-user-justpresty",
                greenNoteContentText: "Honestly, golf lessons should always be this fun.",
                greenNoteCreatedAt: starterSeedDate(year: 2026, month: 6, day: 1, hour: 9, minute: 28)
            ),
            GreenNoteCommentModel(
                greenNoteCommentID: "seed-comment-2",
                greenNoteVideoID: "seed-video-post-1",
                greenNotePublisherID: "seed-user-chloe",
                greenNoteContentText: "Great coach energy, and the tempo is getting better.",
                greenNoteCreatedAt: starterSeedDate(year: 2026, month: 6, day: 2, hour: 10, minute: 5)
            ),
            GreenNoteCommentModel(
                greenNoteCommentID: "seed-comment-3",
                greenNoteVideoID: "seed-video-post-2",
                greenNotePublisherID: "seed-user-batch",
                greenNoteContentText: "Saving this drill for my next range session.",
                greenNoteCreatedAt: starterSeedDate(year: 2026, month: 6, day: 3, hour: 14, minute: 42)
            ),
            GreenNoteCommentModel(
                greenNoteCommentID: "seed-comment-4",
                greenNoteVideoID: "seed-video-post-2",
                greenNotePublisherID: "seed-user-chordsing",
                greenNoteContentText: "The wrist hinge cue finally makes sense now.",
                greenNoteCreatedAt: starterSeedDate(year: 2026, month: 6, day: 3, hour: 15, minute: 8)
            ),
            GreenNoteCommentModel(
                greenNoteCommentID: "seed-comment-5",
                greenNoteVideoID: "seed-video-post-3",
                greenNotePublisherID: "seed-user-justpresty",
                greenNoteContentText: "Team navy looks ready for match play.",
                greenNoteCreatedAt: starterSeedDate(year: 2026, month: 6, day: 4, hour: 11, minute: 31)
            ),
            GreenNoteCommentModel(
                greenNoteCommentID: "seed-comment-6",
                greenNoteVideoID: "seed-video-post-4",
                greenNotePublisherID: "seed-user-chloe",
                greenNoteContentText: "36 holes is a full golf love letter.",
                greenNoteCreatedAt: starterSeedDate(year: 2026, month: 6, day: 5, hour: 18, minute: 16)
            ),
            GreenNoteCommentModel(
                greenNoteCommentID: "seed-comment-7",
                greenNoteVideoID: "seed-video-post-4",
                greenNotePublisherID: "seed-user-lucadorotovics",
                greenNoteContentText: "Respect. My legs would be negotiating after 18.",
                greenNoteCreatedAt: starterSeedDate(year: 2026, month: 6, day: 5, hour: 18, minute: 37)
            )
        ]
    }

    static var starterSeedActivities: [MatchDayActivityModel] {
        [
            MatchDayActivityModel(
                matchDayActivityID: "seed-activity-sunrise-swing-open",
                matchDayPublisherID: "seed-user-chloe",
                matchDayActivityName: "Sunrise Swing Open",
                matchDayCoverAddress: "EULGO_activity_0",
                matchDayIntroductionText: "Start your day with an energizing golf experience at the Sunrise Swing Open. This friendly competition invites players of all skill levels to enjoy morning rounds, connect with fellow golf enthusiasts, and compete in a relaxed atmosphere.",
                matchDayDate: starterSeedDate(year: 2026, month: 6, day: 28),
                matchDayDurationText: "08:00 - 12:00",
                matchDayLocation: "Greenvale Golf Club — North Course",
                matchDayParticipantUserIDs: [
                    "seed-user-chloe",
                    "seed-user-lucadorotovics",
                    "seed-user-justpresty"
                ]
            ),
            MatchDayActivityModel(
                matchDayActivityID: "seed-activity-fairway-social-cup",
                matchDayPublisherID: "seed-user-lucadorotovics",
                matchDayActivityName: "Fairway Social Cup",
                matchDayCoverAddress: "EULGO_activity_1",
                matchDayIntroductionText: "A social golf event designed to combine competition and new connections through rotating team play.",
                matchDayDate: starterSeedDate(year: 2026, month: 7, day: 5),
                matchDayDurationText: "15:00 - 18:00",
                matchDayLocation: "Ocean Crest Golf Course — East Fairway",
                matchDayParticipantUserIDs: [
                    "seed-user-lucadorotovics",
                    "seed-user-batch",
                    "seed-user-chordsing"
                ]
            )
        ]
    }

    static var starterSeedChatRooms: [ClubPairChatRoomModel] {
        [
            ClubPairChatRoomModel(
                clubPairRoomID: "seed-chat-room-chloe-lucadorotovics",
                clubPairUserIDs: [
                    "seed-user-chloe",
                    "seed-user-lucadorotovics"
                ],
                clubPairLastMessageSentAt: starterSeedDate(year: 2026, month: 6, day: 10, hour: 15, minute: 42),
                clubPairLastSenderID: "seed-user-lucadorotovics",
                clubPairLastMessageText: "Range session this weekend?",
                clubPairUnreadMessageCount: 1
            )
        ]
    }

    static var starterSeedChatMessages: [WhisperLineChatMessageModel] {
        [
            WhisperLineChatMessageModel(
                whisperLineMessageID: "seed-chat-message-chloe-lucadorotovics-0",
                whisperLineRoomID: "seed-chat-room-chloe-lucadorotovics",
                whisperLineSenderID: "seed-user-chloe",
                whisperLineTextMessage: "My swing finally feels less chaotic after that drill.",
                whisperLineSentAt: starterSeedDate(year: 2026, month: 6, day: 10, hour: 15, minute: 36)
            ),
            WhisperLineChatMessageModel(
                whisperLineMessageID: "seed-chat-message-chloe-lucadorotovics-1",
                whisperLineRoomID: "seed-chat-room-chloe-lucadorotovics",
                whisperLineSenderID: "seed-user-lucadorotovics",
                whisperLineTextMessage: "Range session this weekend?",
                whisperLineSentAt: starterSeedDate(year: 2026, month: 6, day: 10, hour: 15, minute: 42)
            )
        ]
    }

    static var starterSeedVenues: [LinksMapVenueModel] {
        [
            LinksMapVenueModel(
                linksMapVenueID: "seed-venue-greenvale",
                linksMapPhotoAddresses: ["EULGO_venues_0"],
                linksMapVenueName: "Greenvale Golf Club",
                linksMapIntroductionText: "Nestled among rolling hills and open landscapes, Greenvale Golf Club offers a balanced experience for both beginners and experienced golfers. Designed with wide fairways and thoughtfully placed bunkers, the course emphasizes precision while maintaining an enjoyable pace of play.",
                linksMapVenueSize: 50,
                linksMapStarRating: 4.9
            ),
            LinksMapVenueModel(
                linksMapVenueID: "seed-venue-ocean-crest",
                linksMapPhotoAddresses: ["EULGO_venues_1"],
                linksMapVenueName: "Ocean Crest Golf Course",
                linksMapIntroductionText: "Ocean Crest Golf Course combines luxury and challenge in a modern coastal-inspired setting. The course features flowing layouts, elevated tee boxes, and open green spaces that create a premium golf experience.",
                linksMapVenueSize: 38,
                linksMapStarRating: 4.7
            ),
            LinksMapVenueModel(
                linksMapVenueID: "seed-venue-pinewood-valley",
                linksMapPhotoAddresses: ["EULGO_venues_2"],
                linksMapVenueName: "Pinewood Valley Golf Resort",
                linksMapIntroductionText: "Surrounded by pine forests and peaceful landscapes, Pinewood Valley Golf Resort is designed for players seeking a calm and immersive golfing environment. The course blends natural contours with strategic play zones to create a memorable round.",
                linksMapVenueSize: 64,
                linksMapStarRating: 4.8
            )
        ]
    }

    static var starterSeedVenueRatings: [ScoreCardVenueRatingModel] {
        [
        ]
    }

    static func starterSeedUsersIfNeeded() {
        guard TeeBoxUserStore.teeBoxReadAllUsers().isEmpty else {
            return
        }

        starterSeedUsers.forEach {
            _ = TeeBoxUserStore.teeBoxCreateUser($0)
        }
    }

    static func starterSeedVideoPostsIfNeeded() {
        guard BirdieClipVideoPostStore.birdieClipReadAllPosts().isEmpty else {
            return
        }

        starterSeedVideoPosts.forEach {
            _ = BirdieClipVideoPostStore.birdieClipCreatePost($0)
        }
    }

    static func starterSeedCommentsIfNeeded() {
        guard GreenNoteCommentStore.greenNoteReadAllComments().isEmpty else {
            return
        }

        starterSeedComments.forEach {
            _ = GreenNoteCommentStore.greenNoteCreateComment($0)
        }
    }

    static func starterSeedActivitiesIfNeeded() {
        guard MatchDayActivityStore.matchDayReadAllActivities().isEmpty else {
            return
        }

        starterSeedActivities.forEach {
            _ = MatchDayActivityStore.matchDayCreateActivity($0)
        }
    }

    static func starterSeedChatRoomsIfNeeded() {
        guard ClubPairChatRoomStore.clubPairReadAllRooms().isEmpty else {
            return
        }

        starterSeedChatRooms.forEach {
            _ = ClubPairChatRoomStore.clubPairCreateRoom($0)
        }
    }

    static func starterSeedChatMessagesIfNeeded() {
        guard WhisperLineChatMessageStore.whisperLineReadAllMessages().isEmpty else {
            return
        }

        starterSeedChatMessages.forEach {
            _ = WhisperLineChatMessageStore.whisperLineCreateMessage($0)
        }
    }

    static func starterSeedVenuesIfNeeded() {
        guard LinksMapVenueStore.linksMapReadAllVenues().isEmpty else {
            return
        }

        starterSeedVenues.forEach {
            _ = LinksMapVenueStore.linksMapCreateVenue($0)
        }
    }

    static func starterSeedVenueRatingsIfNeeded() {
        guard ScoreCardVenueRatingStore.scoreCardReadAllRatings().isEmpty else {
            return
        }

        starterSeedVenueRatings.forEach {
            _ = ScoreCardVenueRatingStore.scoreCardCreateRating($0)
        }
    }
}
