//
//  DefaultBrowseUseCase.swift
//  DailyQuest
//
//  Created by jinwoong Kim on 2022/11/29.
//

import Foundation

import RxSwift

final class DefaultBrowseUseCase {
    private let browseRepository: BrowseRepository
    
    init(browseRepository: BrowseRepository) {
        self.browseRepository = browseRepository
    }
}

extension DefaultBrowseUseCase: BrowseUseCase {
    func excute() -> Observable<[BrowseQuest]> {
        return browseRepository.fetch()
    }
}

final class BrowseMockRepo: BrowseRepository {
    func fetch() -> RxSwift.Observable<[BrowseQuest]> {
        return .just([BrowseQuest(user: User(uuid: "", nickName: "test", profileURL: "", backgroundImageURL: "", description: "", allow: false), quests: [])])
    }
}
