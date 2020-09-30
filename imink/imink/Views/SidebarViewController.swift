//
//  SidebarViewController.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit
import Combine

class SidebarViewController: UIViewController {

    private enum SidebarItemType: Int {
        case header, row, expandableRow
    }
    
    private enum SidebarSection: Int {
        case splatoon2
    }
    
    private struct SidebarItem: Hashable, Identifiable {
        let id: UUID
        let type: SidebarItemType
        let title: String
        let subtitle: String?
        let image: UIImage?
        
        static func header(title: String, id: UUID = UUID()) -> Self {
            return SidebarItem(id: id, type: .header, title: title, subtitle: nil, image: nil)
        }
        
        static func expandableRow(title: String, subtitle: String?, image: UIImage?, id: UUID = UUID()) -> Self {
            return SidebarItem(id: id, type: .expandableRow, title: title, subtitle: subtitle, image: image)
        }

        static func row(title: String, subtitle: String?, image: UIImage?, id: UUID = UUID()) -> Self {
            return SidebarItem(id: id, type: .row, title: title, subtitle: subtitle, image: image)
        }
    }
    
    private struct RowIdentifier {
        static let home = UUID()
        static let battleRecord = UUID()
    }

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>!
    private var collectionsSubscriber: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        configureDataSource()
        applyInitialSnapshot()
        
        // Select the first item in the Library section.
        let indexPath = IndexPath(item: 1, section: SidebarSection.splatoon2.rawValue)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        self.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        #endif
    }
    
}

extension SidebarViewController {
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.showsSeparators = false
            configuration.headerMode = .firstItemInSection
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }
        return layout
    }
    
}

extension SidebarViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sidebarItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch indexPath.section {
        case SidebarSection.splatoon2.rawValue:
            didSelectLibraryItem(sidebarItem, at: indexPath)
//        case SidebarSection.collections.rawValue:
//            didSelectCollectionsItem(sidebarItem, at: indexPath)
        default:
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    private func didSelectLibraryItem(_ sidebarItem: SidebarItem, at indexPath: IndexPath) {
//        guard let battleRecordListViewController = self.battleRecordListViewController() else { return }
        
        switch sidebarItem.id {
        case RowIdentifier.home:
            print("show home")
        case RowIdentifier.battleRecord:
            print("show battle list")
//            battleRecordListViewController.showRecipes(.all)
//        case RowIdentifier.favorites:
//            battleRecordListViewController.showRecipes(.favorites)
//        case RowIdentifier.recents:
//            battleRecordListViewController.showRecipes(.recents)
        default:
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return indexPath.item == 1
//    }
    
//    private func didSelectCollectionsItem(_ sidebarItem: SidebarItem, at indexPath: IndexPath) {
//        if let battleRecordListViewController = self.battleRecordListViewController() {
//            let collection = sidebarItem.title
//            battleRecordListViewController.showRecipes(from: collection)
//        }
//    }
    
}

extension SidebarViewController {
    
    private func configureDataSource() {
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
            (cell, indexPath, item) in
            
            var contentConfiguration = UIListContentConfiguration.sidebarHeader()
            contentConfiguration.text = item.title
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .subheadline)
            contentConfiguration.textProperties.color = .secondaryLabel
            
            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.outlineDisclosure()]
        }
        
        let expandableRowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
            (cell, indexPath, item) in
            
            var contentConfiguration = UIListContentConfiguration.sidebarSubtitleCell()
            contentConfiguration.text = item.title
            contentConfiguration.secondaryText = item.subtitle
            contentConfiguration.image = item.image
            
            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.outlineDisclosure()]
        }
        
        let rowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
            (cell, indexPath, item) in
            
            var contentConfiguration = UIListContentConfiguration.sidebarSubtitleCell()
            contentConfiguration.text = item.title
            contentConfiguration.secondaryText = item.subtitle
            contentConfiguration.image = item.image
            
            cell.contentConfiguration = contentConfiguration
        }
        
        dataSource = UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell in
            
            switch item.type {
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            case .expandableRow:
                return collectionView.dequeueConfiguredReusableCell(using: expandableRowRegistration, for: indexPath, item: item)
            default:
                return collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: item)
            }
        }
    }
    
    private func homeSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        let header = SidebarItem.header(title: "Splatoon 2")
        let items: [SidebarItem] = [
            .row(title: TabBarItem.home.title(), subtitle: nil, image: TabBarItem.home.image(), id: RowIdentifier.home),
            .row(title: TabBarItem.battleRecord.title(), subtitle: nil, image: TabBarItem.battleRecord.image(), id: RowIdentifier.battleRecord),
        ]

        snapshot.append([header])
        snapshot.expand([header])
        snapshot.append(items, to: header)
        return snapshot
    }
    
    private func applyInitialSnapshot() {
        dataSource.apply(homeSnapshot(), to: .splatoon2, animatingDifferences: false)
    }
    
}
