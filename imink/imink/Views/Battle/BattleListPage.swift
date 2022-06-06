//
//  BattleListPage.swift
//  imink
//
//  Created by Jone Wang on 2021/2/8.
//

import SwiftUI

struct BattleListPage: View {
    @EnvironmentObject var mainViewModel: MainViewModel

    @StateObject var viewModel = BattleListViewModel()

    @State private var rows: [BattleListRowModel] = []
    @State private var battleDetailPresented: Bool = false
    @State private var allowScrollingToSelected: Bool = false
    @State private var selectedRow: BattleListRowModel?

    @State private var currentRecordIdInDetail: Int64?

    let filterItems: [(String, String)] = [
        ("All Rules", ""), ("Turf War", "RegularBattleMono"),
        ("Splat Zones", "SplatZonesMono"), ("Tower Control", "TowerControlMono"),
        ("Rainmaker", "RainmakerMono"), ("Clam Blitz", "ClamBlitzMono")
    ]

    var body: some View {
        Group {
            if viewModel.isLogined {
                NavigationView {
                    content
                        .fixSafeareaBackground()
                        .navigationBarTitle("Battles", displayMode: .inline)
                        .navigationBarHidden(false)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Menu {
                                    Picker(selection: $viewModel.currentFilterIndex, label: Text("filtering options")) {
                                        ForEach(0 ..< filterItems.count) { i in
                                            let item = filterItems[i]
                                            HStack {
                                                Text(item.0.localized)
                                                Image(item.1, bundle: Bundle.inkCore)
                                                    .foregroundColor(.primary)
                                            }.tag(i)
                                        }
                                    }
                                }
                                label: {
                                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle" + (viewModel.currentFilterIndex == 0 ? "" : ".fill"))
                                }
                            }
                        }
                }
                .navigationViewStyle(.automatic)
            } else {
                NavigationView {
                    ZStack { }
                        .fixSafeareaBackground()
                        .modifier(LoginViewModifier(isLogined: false, iconName: "TabBarBattle"))
                        .navigationBarTitle("Battles", displayMode: .inline)
                        .navigationBarHidden(false)
                }
                .navigationViewStyle(.stack)
            }
        }
        .onReceive(mainViewModel.$isLogined) { isLogined in
            viewModel.updateLoginStatus(isLogined: isLogined)
        }
    }

    var content: some View {
        ZStack {
            ScrollViewReader { proxy in
                NavigationLink(
                    destination: detailPage,
                    isActive: $battleDetailPresented
                ) { EmptyView() }

                ScrollView {
                    LazyVStack {
                        ForEach(rows, id: \.id) { row in
                            ZStack {
                                BattleListItemView(
                                    row: row,
                                    selectedId: $viewModel.selectedRowId
                                )
                                .padding([.leading, .trailing])
                                .onTapGesture {
                                    viewModel.selectedRowId = row.id
                                    selectedRow = row
                                    battleDetailPresented = true
                                }
                            }
                            .id(row.id)
                        }
                    }
                    .padding([.top, .bottom], 16)
                }
                .onChange(of: currentRecordIdInDetail) { recordId in
                    if allowScrollingToSelected {
                        withAnimation {
                            proxy.scrollTo(recordId, anchor: .center)
                        }
                    }
                }
            }
        }
        .onAppear {
            self.rows = viewModel.rows
        }
        .onDisappear {
            self.allowScrollingToSelected = true
        }
        .onChange(of: viewModel.rows) { rows in
            withAnimation {
                self.rows = rows
            }
        }
        .onChange(of: battleDetailPresented) { newValue in
            if !newValue {
                viewModel.selectedRowId = nil
            }
        }
    }

    var detailPage: some View {
        Group {
            if let row = selectedRow {
                BattleDetailPageContainer(
                    viewModel: BattleDetailContainerViewModel(
                        records: viewModel.$databaseRecords.eraseToAnyPublisher(),
                        record: row.record,
                        initPageId: row.id,
                        filterIndex: viewModel.currentFilterIndex
                    ),
                    showPage: { pageId in
                        if battleDetailPresented {
                            currentRecordIdInDetail = pageId
                            viewModel.selectedRowId = pageId
                        }
                    },
                    initPageId: row.id,
                    isPresented: $allowScrollingToSelected,
                    selectedRow: row
                )
            } else {
                EmptyView()
            }
        }
    }
}

struct BattleListPage_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BattleListViewModel()
        BattleListPage(viewModel: viewModel)
    }
}
