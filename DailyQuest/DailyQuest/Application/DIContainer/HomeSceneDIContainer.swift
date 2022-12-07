//
//  HomeSceneDIContainer.swift
//  DailyQuest
//
//  Created by jinwoong Kim on 2022/11/16.
//

import UIKit

final class HomeSceneDIContainer {
    
    lazy var questsStorage: QuestsStorage = RealmQuestsStorage()
    
    // MARK: - Repositories
    func makeQuestsRepository() -> QuestsRepository {
        return DefaultQuestsRepository(persistentStorage: questsStorage)
    }
    
    // MARK: - Use Cases
    func makeQuestUseCase() -> QuestUseCase {
        return DefaultQuestUseCase(questsRepository: makeQuestsRepository())
    }
    
    func makeEnrollUseCase() -> EnrollUseCase {
        return DefaultEnrollUseCase(questsRepository: makeQuestsRepository())
    }
    
    // MARK: - View Models
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(questUseCase: makeQuestUseCase())
    }
    
    func makeEnrollViewModel() -> EnrollViewModel {
        return EnrollViewModel(enrollUseCase: makeEnrollUseCase())
    }
    
    // MARK: - View Controller
    func makeHomeViewController() -> HomeViewController {
        return HomeViewController.create(with: makeHomeViewModel())
    }
    
    func makeEnrollViewController() -> EnrollViewController {
        return EnrollViewController.create(with: makeEnrollViewModel())
    }
    
    // MARK: - Flow
    func makeHomeCoordinator(navigationController: UINavigationController,
                             homeSceneDIContainer: HomeSceneDIContainer) -> HomeCoordinator {
        return DefaultHomeCoordinator(navigationController: navigationController,
                                      homeSceneDIContainer: homeSceneDIContainer)
    }
}
