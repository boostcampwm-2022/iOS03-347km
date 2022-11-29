//
//  UserInfoEntity.swift
//  DailyQuest
//
//  Created by 이전희 on 2022/11/15.
//

import Foundation
import RealmSwift

final class UserInfoEntity: Object {
    @Persisted var uuid: String
    @Persisted var nickName: String
    @Persisted var profileURL: String
    @Persisted var backgroundImageURL: String
    @Persisted var userDescription: String
    @Persisted var allow: Bool

    override init() { }

    init(uuid: String, nickName: String, profileURL: String, backgroundImageURL: String, description: String, allow: Bool) {
        self.uuid = uuid
        self.nickName = nickName
        self.profileURL = profileURL
        self.backgroundImageURL = backgroundImageURL
        self.userDescription = description
        self.allow = allow
    }
    
    override class func primaryKey() -> String? {
        "uuid"
    }
}
