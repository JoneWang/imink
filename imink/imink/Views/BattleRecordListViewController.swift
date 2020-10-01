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

    static let storyboardID = "BattleRecordList"

    static func instantiateFromStoryboard() -> BattleRecordListViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(identifier: storyboardID) as? BattleRecordListViewController
    }

    @IBOutlet weak var collectionView: UICollectionView!

    private var cancelBag = Set<AnyCancellable>()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Record>!

    private var battleListViewModel: BattleListViewModel!
    private var selectedRecord: Record? {
        guard
            let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems,
            let selectedIndexPath = indexPathsForSelectedItems.first,
            let selectedRecord = dataSource.itemIdentifier(for: selectedIndexPath)
            else { return nil }

        return selectedRecord
    }

    private var selectEnabled = true

    enum Section: Int {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        battleListViewModel = BattleListViewModel()

        configureCollectionView()
        configureDataSource()

        // Listen for record changes in the data store.
        battleListViewModel.$records
            .sink { [weak self] records in
                guard let `self` = self else { return }

                // Update real time
                if let indexPathsForSelectedItems = self.collectionView.indexPathsForSelectedItems,
                   let selectedIndexPath = indexPathsForSelectedItems.first,
                   selectedIndexPath.row == 0,
                   let firstRecord = records.first,
                   (firstRecord.battleNumber != self.selectedRecord?.battleNumber) ||
                        self.selectedRecord == nil ||
                        (firstRecord.battleNumber == self.selectedRecord?.battleNumber && firstRecord.isDetail != self.selectedRecord?.isDetail) {
                    // Update list
                    self.apply(records) {
                        if self.traitCollection.userInterfaceIdiom == .pad ||
                            self.traitCollection.userInterfaceIdiom == .mac {
                            let indexPath = IndexPath(item: 0, section: 0)
                            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                            self.collectionView(self.collectionView, didSelectItemAt: indexPath)
                        }
                    }
                } else {
                    // Update list
                    self.apply(records) {
                        if self.selectedRecord == nil {
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

        // Title
        battleListViewModel.$databaseRecords
            .sink { records in
                // Title
                let allRecordCount = records.count
                let synchronizedDetailRecordCount = records.filter { $0.isDetail }.count
                if (allRecordCount == synchronizedDetailRecordCount) {
                    self.title = "Records"
                } else {
                    self.title = "\(synchronizedDetailRecordCount)/\(allRecordCount)"
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
        let record = dataSource.itemIdentifier(for: indexPath)

        if let splitVC = splitViewController,
           let battleDetailViewController = splitVC.viewControllers.last as? BattleDetailViewController {
            battleDetailViewController.record = record
        } else if let navVC = navigationController,
                  let battleDetailViewController = navVC.viewControllers.last as? BattleDetailViewController {
            battleDetailViewController.record = record
        } else {
            guard let battleDetailViewController = BattleDetailViewController.instantiateFromStoryboard() else { return }
            battleDetailViewController.record = record
            let navigationController = UINavigationController(rootViewController: battleDetailViewController)
            showDetailViewController(navigationController, sender: self)
        }

        selectEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.selectEnabled = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let record = dataSource.itemIdentifier(for: indexPath) else {
            return false
        }

        return record.isDetail && selectEnabled
    }

}

extension BattleRecordListViewController {

    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = createCollectionViewLayout()
    }

    func createCollectionViewLayout() -> UICollectionViewLayout {
        let recordItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let recordItem = NSCollectionLayoutItem(layoutSize: recordItemSize)
        recordItem.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 10.0, bottom: 5.0, trailing: 10.0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: recordItem, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }

}

extension BattleRecordListViewController {

    func configureDataSource() {
        let recordCell = UICollectionView.CellRegistration<BattleRecordListCell, Record>(cellNib: BattleRecordListCell.nib) { (cell, _, record) in
            cell.record = record
        }
        
        let realTimeCell = UICollectionView.CellRegistration<BattleRecordListRealTimeCell, Record>(cellNib: BattleRecordListRealTimeCell.nib) { (cell, _, record) in
            cell.record = record
        }

        // Create a diffable data source, and configure the cell with record data.
        dataSource = UICollectionViewDiffableDataSource<Section, Record>(collectionView: collectionView) { (
            collectionView: UICollectionView,
            indexPath: IndexPath,
            record: Record) -> UICollectionViewCell? in
            if record.id != nil {
                return collectionView.dequeueConfiguredReusableCell(using: recordCell, for: indexPath, item: record)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: realTimeCell, for: indexPath, item: record)
            }
        }
    }

    func apply(_ records: [Record], completed: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, Record>()
            snapshot.appendSections([.main])
            snapshot.appendItems(records)
            self.dataSource.apply(snapshot, animatingDifferences: true) {
                completed()
            }
        }
    }

}
