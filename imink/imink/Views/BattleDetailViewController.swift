//
//  BattleDetailViewController.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit
import SwiftUI
import Combine
import os

class BattleDetailViewController: UIViewController {
    
    let regularViewMinWidth: CGFloat = 428
    
    static let storyboardID = "BattleDetail"
    static func instantiateFromStoryboard() -> BattleDetailViewController? {
        let storyboard = UIStoryboard(name: "BattleDetail", bundle: .main)
        return storyboard.instantiateViewController(identifier: storyboardID) as? BattleDetailViewController
    }
    
    class UpdateModel: ObservableObject {
        @Published var battle: Battle
        
        init(battle: Battle) {
            self.battle = battle
        }
    }
    
    var battle: Battle? {
        didSet {
            guard let battle = battle else {
                return
            }
            
            title = "ID: \(battle.battleNumber)"
            
            if updateModel == nil {
                updateModel = UpdateModel(battle: battle)
            } else {
                updateModel.battle = battle
            }
        }
    }
    
    @IBOutlet weak var fullScreenSwitchButton: UIBarButtonItem!
    
    private var cancelBag = Set<AnyCancellable>()
    private var updateModel: UpdateModel!
    private var battleDetailView: UIView!
    
    private var isCompact: Bool {
        let width = self.view.frame.size.width - (self.view.safeAreaInsets.left + self.view.safeAreaInsets.right)
        let height = self.view.frame.size.height - (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom)
        return traitCollection.horizontalSizeClass == .compact ||
            traitCollection.verticalSizeClass == .compact ||
            width <= regularViewMinWidth ||
            width <= height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AppUIColor.listBackgroundColor
        
        // Detail
        if isCompact {
            configureCompactView()
        } else {
            configureRegularView()
        }
        
        // Notification
        let notificationCenter = NotificationCenter.default
        
        notificationCenter
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                self?.traitCollectionDidChange(nil)
            }
            .store(in: &cancelBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let splitViewController = self.splitViewController {
            navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
        
        #if targetEnvironment(macCatalyst)
        navigationController?.navigationBar.isHidden = true
        navigationController?.setToolbarHidden(true, animated: animated)
        #endif
    }
    
    func configureCompactView() {
        if let battleDetailView = battleDetailView {
            battleDetailView.removeFromSuperview()
        }
        
        let hostingController = UIHostingController(rootView: BattleDetailPage(model: updateModel))
        addChild(hostingController)
        
        battleDetailView = hostingController.view
        battleDetailView.backgroundColor = AppUIColor.listBackgroundColor

        view.addSubview(battleDetailView)
        battleDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
//    func configureRegularView() {
//        if let battleDetailView = battleDetailView {
//            battleDetailView.removeFromSuperview()
//        }
//
//        let hostingController = UIHostingController(rootView: BattleDetailPage(model: updateModel))
//        addChild(hostingController)
//
//        battleDetailView = hostingController.view
//
//        view.addSubview(battleDetailView)
//        battleDetailView.snp.makeConstraints {
//            $0.top.bottom.equalToSuperview()
//            $0.centerX.equalToSuperview()
//            let viewWidth = self.view.frame.size.width
//            if viewWidth > 428 {
//                $0.width.equalTo(428)
//            } else {
//                $0.width.equalTo(viewWidth)
//            }
//        }
//    }
    
    func configureRegularView() {
        if let battleDetailView = battleDetailView {
            battleDetailView.removeFromSuperview()
        }
        
        let hostingController = UIHostingController(rootView: RegularBattlePage(model: updateModel))
        addChild(hostingController)
        battleDetailView = hostingController.view
        
        view.addSubview(battleDetailView)
        battleDetailView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if isCompact {
            configureCompactView()
        } else {
            configureRegularView()
        }
    }
    
}
