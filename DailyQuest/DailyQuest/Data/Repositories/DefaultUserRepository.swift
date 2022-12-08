//
//  DefaultUserRepository.swift
//  DailyQuest
//
//  Created by 이전희 on 2022/12/01.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultUserRepository {
    
    private let persistentStorage: UserInfoStorage
    private let networkService: NetworkService
    
    private let disposeBag = DisposeBag()
    
    init(persistentStorage: UserInfoStorage, networkService: NetworkService = FirebaseService.shared) {
        self.persistentStorage = persistentStorage
        self.networkService = networkService
    }
}

extension DefaultUserRepository: UserRepository {
    func isLoggedIn() -> BehaviorRelay<String?> {
        return networkService.uid
    }
    
    func readUser() -> Single<User> {
        return self.persistentStorage.fetchUserInfo()
            .catch { [weak self] _ in
                guard let self = self else { return Observable.just(User()) }
                return self.fetchUserNetworkService()
            }
            .asSingle()
    }
    
    func updateUser(by user: User) -> Single<User> {
        return persistentStorage.updateUserInfo(user: user)
            .asObservable()
            .flatMap(updateUserNetworkService(user:))
            .asSingle()
    }
    
    func fetchUser(by uuid: String) -> Single<User> {
        return networkService.read(type: UserDTO.self,
                                   userCase: .anotherUser(uuid),
                                   access: .userInfo,
                                   filter: nil)
        .map { $0.toDomain() }
        .asSingle()
    }
    
    func saveProfileImage(data: Data) -> Single<Bool> {
        networkService.uploadDataStorage(data: data, path: .profileImages)
            .flatMap { [weak self] downloadUrl in
                guard let self = self else { return Single.just(User()) }
                return self.persistentStorage.fetchUserInfo()
                    .flatMap { user in
                        self.networkService.deleteDataStorage(forUrl: user.profileURL)
                            .catchAndReturn(false)
                            .map{ _ in user }
                    }
                    .map { $0.setProfileImageURL(profileURL: downloadUrl) }
                    .asSingle()
            }
            .flatMap(updateUser(by:))
            .map { _ in true }
            .catchAndReturn(false)
            .do(afterSuccess: { _ in
                NotificationCenter.default.post(name: .userUpdated, object: nil)
            })
    }
    
    func saveBackgroundImage(data: Data) -> Single<Bool> {
        networkService.uploadDataStorage(data: data, path: .backgroundImages)
            .flatMap { [weak self] downloadUrl in
                guard let self = self else { return Single.just(User()) }
                return self.persistentStorage.fetchUserInfo()
                    .flatMap { user in
                        self.networkService.deleteDataStorage(forUrl: user.backgroundImageURL)
                            .catchAndReturn(false)
                            .map{ _ in user }
                    }
                    .map { $0.setBackgroundImageURL(backgroundImageURL: downloadUrl) }
                    .asSingle()
            }
            .flatMap(updateUser(by:))
            .map { _ in true }
            .catchAndReturn(false)
            .do(afterSuccess: { _ in
                NotificationCenter.default.post(name: .userUpdated, object: nil)
            })
                }
    
}

extension DefaultUserRepository: ProtectedUserRepository {
    func deleteUser() -> Observable<Bool> {
        return networkService
            .delete(userCase: .currentUser, access: .userInfo, dto: UserDTO())
            .flatMap { [weak self] _ in
                guard let self = self else { return .just(true) }
                return self.networkService.deleteUser() }
            .map { _ in true }
            .catchAndReturn(false)
            .asObservable()
            .do(onNext: { [weak self]_ in
                guard let self = self else { return }
                self.networkService.signOut().subscribe()
                    .disposed(by: self.disposeBag)
            })
    }
}

private extension DefaultUserRepository {
    func fetchUserNetworkService() -> Observable<User> {
        networkService.read(type: UserDTO.self, userCase: .currentUser, access: .userInfo, filter: nil)
            .map { $0.toDomain() }
    }
    
    func updateUserNetworkService(user: User) -> Observable<User> {
        networkService.update(userCase: .currentUser, access: .userInfo, dto: user.toDTO())
            .map { $0.toDomain() }
            .asObservable()
            .catchAndReturn(user)
    }
}

