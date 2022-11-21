//
//  RealmUserQuestsStorage.swift
//  DailyQuest
//
//  Created by 이전희 on 2022/11/14.
//

import Foundation
import RxSwift

final class RealmUserQuestsStorage {

    private let realmStorage: RealmStorage

    init(realmStorage: RealmStorage = RealmStorage.shared) {
        self.realmStorage = realmStorage
    }
}

extension RealmUserQuestsStorage: UserQuestsStorage {

    func saveQuests(with quests: [Quest]) -> Single<[Quest]> {
        return Single.create { [weak self] single in
            guard let realmStorage = self?.realmStorage else {
                return Disposables.create()
            }

            for quest in quests {
                let questEntity = UserQuestEntity(quest: quest)
                do {
                    try realmStorage.saveEntity(entity: questEntity)
                } catch let error {
                    single(.failure(RealmStorageError.saveError(error)))
                    return Disposables.create()
                }
            }

            single(.success(quests))
            return Disposables.create()
        }
    }

    func fetchQuests(by date: Date) -> Observable<[Quest]> {
        return Observable<[Quest]>.create { [weak self] observer in
            guard let realmStorage = self?.realmStorage else {
                return Disposables.create()
            }

            do {
                let quests = try realmStorage
                    .fetchEntities(type: UserQuestEntity.self, filter: "date == \(date.toString)")
                    .compactMap { $0.toDomain() }
                observer.onNext(quests)
                observer.onCompleted()
            } catch let error {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    func updateQuest(with quest: Quest) -> Single<Quest> {
        return Single.create { [weak self] single in
            guard let realmStorage = self?.realmStorage else {
                return Disposables.create()
            }

            let questEntity = UserQuestEntity(quest: quest)
            do {
                try realmStorage.updateEntity(entity: questEntity)
            } catch let error {

                single(.failure(RealmStorageError.saveError(error)))
                return Disposables.create()
            }

            return Disposables.create()
        }
    }

    func deleteQuest(with questId: UUID) -> Single<Quest> {
        return Single.create { [weak self] single in
            guard let realmStorage = self?.realmStorage else {
                return Disposables.create()
            }

            do {
                guard let entity = try realmStorage.findEntities(type: UserQuestEntity.self, filter: "uuid == \(questId)").first else {
                    throw RealmStorageError.noDataError
                }
                try realmStorage.deleteEntity(entity: entity)
            } catch let error {

                single(.failure(RealmStorageError.saveError(error)))
                return Disposables.create()
            }

            return Disposables.create()
        }

    }

    func deleteQuestGroup(with groupId: UUID) -> Single<[Quest]> {
        return Single.create { [weak self] single in
            guard let realmStorage = self?.realmStorage else {
                return Disposables.create()
            }

            do {
                let entities = try realmStorage.findEntities(type: UserQuestEntity.self, filter: "groupId == \(groupId)")
                for entity in entities {
                    try realmStorage.deleteEntity(entity: entity)
                }
            } catch let error {

                single(.failure(RealmStorageError.saveError(error)))
                return Disposables.create()
            }
            
            return Disposables.create()
        }
    }
}
