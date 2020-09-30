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
    
    static let storyboardID = "BattleDetail"
    static func instantiateFromStoryboard() -> BattleDetailViewController? {
        let storyboard = UIStoryboard(name: "BattleDetail", bundle: .main)
        return storyboard.instantiateViewController(identifier: storyboardID) as? BattleDetailViewController
    }
    
    class UpdateModel: ObservableObject {
        @Published var record: Record?
    }
    
    var record: Record? {
        didSet {
            updateModel.record = record
            
            if let record = record {
                title = "ID:\(record.battleNumber)"
            }
        }
    }
    
    @IBOutlet weak var fullScreenSwitchButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var scrollView: UIScrollView?
    var battleDetailView: UIView!
    
    private var cancelBag = Set<AnyCancellable>()
    
    private var updateModel = UpdateModel()
    
    private var isFullScreen = false {
        didSet {
            fullScreenSwitchButton.image = UIImage(
                systemName: isFullScreen ?
                    "arrow.down.right.and.arrow.up.left" :
                    "arrow.up.left.and.arrow.down.right"
            )
        }
    }
    
    private var isInitLayout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // On iPhone
        if traitCollection.horizontalSizeClass == .compact {
            navigationItem.rightBarButtonItems = [self.shareButton]
        }
        
        // Detail
        if traitCollection.horizontalSizeClass == .compact {
            let hostingController = UIHostingController(rootView: CompactBattlePage(model: updateModel))
            addChild(hostingController)
            
            let scrollView = UIScrollView()
            scrollView.contentInsetAdjustmentBehavior = .never
            view.addSubview(scrollView)
            scrollView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            battleDetailView = hostingController.view
            scrollView.addSubview(battleDetailView)
            
            self.scrollView = scrollView
        } else {
            let hostingController = UIHostingController(rootView: RegularBattlePage(model: updateModel))
            addChild(hostingController)
            battleDetailView = hostingController.view
            
            view.addSubview(battleDetailView)
            battleDetailView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        // Notification
        let notificationCenter = NotificationCenter.default
        notificationCenter
            .publisher(for: .splitVCDisplayMode)
            .receive(on: RunLoop.main)
            .map { ($0.object as! UISplitViewController.DisplayMode) == .secondaryOnly }
            .sink { [weak self] in
                self?.isFullScreen = $0
            }
            .store(in: &cancelBag)
        
        notificationCenter
            .publisher(for: .share)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                self?.shareBattle(notification.object)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isInitLayout, let scrollView = scrollView {
            self.battleDetailView.snp.remakeConstraints {
                $0.edges.equalToSuperview()
                $0.width.equalTo(self.view)
                $0.width.equalTo(self.battleDetailView.snp.height).multipliedBy(375.0 / (812.0 - scrollView.safeAreaInsets.top))
            }
            
            scrollView.contentInset = .init(top: scrollView.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
            
            isInitLayout = true
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        print(traitCollection.horizontalSizeClass)
    }
    
}

// MARK: - Actions

extension BattleDetailViewController {
    
    @IBAction func toggleFullScreen(_ sender: Any) {
        isFullScreen.toggle()
        
        if let splitViewController = self.splitViewController {
            splitViewController.preferredDisplayMode = isFullScreen ? .secondaryOnly : .oneBesideSecondary
        }
    }
    
    @IBAction func shareBattle(_ sender: Any?) {
        // Add share icon
        var shareIconImageView: UIImageView?
        if let shareIcon = UIImage(named: "Share") {
            let imageView = UIImageView(image: shareIcon)
            battleDetailView.addSubview(imageView)

            imageView.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-18)
            }
            battleDetailView.layoutIfNeeded()

            shareIconImageView = imageView
        }

        // Snapshot
        let image = battleDetailView.snapshot()

        // Remove share icon
        shareIconImageView?.removeFromSuperview()
        
//        guard let shareSnapshotView = battleDetailView.snapshotView(afterScreenUpdates: true) else { return }
//
//        // Add share icon
//        if let shareIcon = UIImage(named: "Share") {
//            let imageView = UIImageView(image: shareIcon)
//            shareSnapshotView.addSubview(imageView)
//
//            imageView.snp.makeConstraints {
//                $0.centerX.equalToSuperview()
//                $0.bottom.equalToSuperview().offset(-18)
//            }375.0 / 812.0
//            shareSnapshotView.layoutIfNeeded()
//        }
//
//        // Snapshot to image
//        let image = shareSnapshotView.snapshot()
        
        let items: [Any] = [image]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activity, completed, items, error in
            os_log("Activity completed: %s", completed ? "true" : "false")
        }
        
        if traitCollection.userInterfaceIdiom == .pad {
            if let popover = activityViewController.popoverPresentationController {
                if let barButtonItem = sender as? UIBarButtonItem {
                    popover.barButtonItem = barButtonItem
                    popover.canOverlapSourceViewRect = true
                }
            }
        } else if traitCollection.userInterfaceIdiom == .mac {
            // TODO:
            activityViewController.popoverPresentationController?.sourceView = view
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
}
