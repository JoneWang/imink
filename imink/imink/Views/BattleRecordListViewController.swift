//
//  BattleRecordListViewController.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit
import Combine
import SwiftUI

class BattleRecordListViewController: UIViewController {
    
    class UpdateModel: ObservableObject {
        @Published var battle: Battle
        
        init(battle: Battle) {
            self.battle = battle
        }
    }

    static let storyboardID = "BattleRecordList"

    static func instantiateFromStoryboard() -> BattleRecordListViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(identifier: storyboardID) as? BattleRecordListViewController
    }

    @IBOutlet weak var collectionView: UICollectionView!

    private var cancelBag = Set<AnyCancellable>()

    private var dataSource: UICollectionViewDiffableDataSource<Section, BattleListRowModel>!

    private var battleListViewModel: BattleListViewModel!
    private var selectedRow: BattleListRowModel? {
        guard
            let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems,
            let selectedIndexPath = indexPathsForSelectedItems.first,
            let selectedRow = dataSource.itemIdentifier(for: selectedIndexPath)
            else { return nil }

        return selectedRow
    }

    private var selectEnabled = true
    
    private var updateModel: UpdateModel!

    enum Section: Int {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Battles".localized
        
        battleListViewModel = BattleListViewModel()

        configureCollectionView()
        configureDataSource()

        // Listen for record changes in the data store.
        battleListViewModel.$rows
            .sink { [weak self] rows in
                guard let `self` = self else { return }
                
                // TODO: Pagination
                let animated = true

                let selectedRecord = self.selectedRow?.record
                
                // Update real time
                if let indexPathsForSelectedItems = self.collectionView.indexPathsForSelectedItems,
                   let selectedIndexPath = indexPathsForSelectedItems.first,
                   selectedIndexPath.row == 0,
                   let firstRecord = rows.first?.record,
                   (firstRecord.battleNumber != selectedRecord?.battleNumber ||
                        self.selectedRow == nil ||
                        firstRecord.battleNumber == selectedRecord?.battleNumber) {
                    // Update list
                    self.apply(rows, animated: animated) {
                        let indexPath = IndexPath(item: 0, section: 0)
                        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                        self.collectionView(self.collectionView, didSelectItemAt: indexPath)
                    }
                } else {
                    // Update list
                    self.apply(rows, animated: animated) {
                        if self.selectedRow == nil {
                            if self.traitCollection.userInterfaceIdiom == .pad ||
                                self.traitCollection.userInterfaceIdiom == .mac {
                                let indexPath = IndexPath(item: 0, section: 0)
                                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                                self.collectionView(self.collectionView, didSelectItemAt: indexPath)
                            }
                        }
                    }
                }

            }
            .store(in: &cancelBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if traitCollection.userInterfaceIdiom == .mac {
            // Hide navigation bar on Mac
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if traitCollection.userInterfaceIdiom == .phone {
            // Deselect on iPhone
            if let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems,
               let selectedIndexPath = indexPathsForSelectedItems.first {
                collectionView.deselectItem(at: selectedIndexPath, animated: true)
            }
        }
    }

}

extension BattleRecordListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = dataSource.itemIdentifier(for: indexPath)

        guard let recordId = row?.record?.id,
              let record = AppDatabase.shared.record(with: recordId),
              let battle = record.battle else {
            return
        }
        
        if let splitVC = splitViewController,
           let _ = splitVC.viewControllers.last as? UIHostingController<BattleDetailPage> {
            updateModel.battle = battle
        } else if let navVC = navigationController,
                  let detailNavVC = navVC.viewControllers.last as? UINavigationController,
                  let _ = detailNavVC.viewControllers.last as? UIHostingController<BattleDetailPage> {
            updateModel.battle = battle
        } else {
            updateModel = UpdateModel(battle: battle)
            let battleDetailViewController = UIHostingController(rootView: BattleDetailPage(model: updateModel))
            let navigationController = UINavigationController(rootViewController: battleDetailViewController)
            showDetailViewController(navigationController, sender: self)
        }

        selectEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.selectEnabled = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let row = dataSource.itemIdentifier(for: indexPath),
              let record = row.record else {
            return false
        }

        return selectEnabled
    }
    
    // TODO: Pagination
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let battleRecordListCell = cell as? BattleRecordListCell {
//            let record = battleRecordListCell.record
//
//            if battleListViewModel.records.count >= 3,
//               record == battleListViewModel.records[battleListViewModel.records.count - 3] {
//                battleListViewModel.nextPage()
//            }
//            else if record == battleListViewModel.records.last {
//                battleListViewModel.nextPage()
//            }
//        }
//    }

}

extension BattleRecordListViewController {

    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.backgroundColor = AppUIColor.listBackgroundColor
        collectionView.contentInset = .init(top: 12, left: 0, bottom: 12, right: 0)
    }

    func createCollectionViewLayout() -> UICollectionViewLayout {
        let recordItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let recordItem = NSCollectionLayoutItem(layoutSize: recordItemSize)
        recordItem.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 16.0, bottom: 4, trailing: 16.0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(87.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: recordItem, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }

}

extension BattleRecordListViewController {

    func configureDataSource() {
        let recordCell = UICollectionView.CellRegistration<BattleRecordListCell, BattleListRowModel>(cellNib: BattleRecordListCell.nib) { (cell, _, row) in
            cell.record = row.record
        }
        
        let realTimeCell = UICollectionView.CellRegistration<BattleRecordListRealTimeCell, BattleListRowModel>(cellNib: BattleRecordListRealTimeCell.nib) { (cell, _, row) in
            cell.record = row.record
        }

        // Create a diffable data source, and configure the cell with record data.
        dataSource = UICollectionViewDiffableDataSource<Section, BattleListRowModel>(collectionView: collectionView) { (
            collectionView: UICollectionView,
            indexPath: IndexPath,
            row: BattleListRowModel) -> UICollectionViewCell? in
            if row.type == .realtime {
                return collectionView.dequeueConfiguredReusableCell(using: realTimeCell, for: indexPath, item: row)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: recordCell, for: indexPath, item: row)
            }
        }
    }

    func apply(_ rows: [BattleListRowModel], animated: Bool = true, completed: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let `self` = self else { return }
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, BattleListRowModel>()
            snapshot.appendSections([.main])
            snapshot.appendItems(rows)
            self.dataSource.apply(snapshot, animatingDifferences: animated) {
                completed()
            }
        }
    }

}
