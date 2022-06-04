//
//  BattleDetailPageContainer.swift
//  imink
//
//  Created by Jone Wang on 2022/3/4.
//

import SwiftUI

struct BattleDetailPageContainer: View {
    @EnvironmentObject var synchronizeBattleViewModel: SynchronizeBattleViewModel

    @StateObject var viewModel: BattleDetailContainerViewModel
    @StateObject private var avatarViewModel = AvatarViewModel()

    var showPage: (Int64) -> Void
    @State var initPageId: Int64
    @Binding var isPresented: Bool

    @State private var showPlayerSkill: Bool = false
    @State private var hoveredMember: Bool = false
    @State private var activePlayer: Player? = nil
    @State private var activePlayerVictory: Bool = false
    @State private var showFloatButton: Bool = false

    @State private var hidePlayerNames: Bool = false
    
    var selectedRow: BattleListRowModel

    private var navigationTitle: String {
        "ID: \(viewModel.currentBattleNumber)"
    }

    private var onlyOne: Bool {
        synchronizeBattleViewModel.synchronizing
    }

    var body: some View {
        ScrollViewReader { proxy in
            Group {
                // Do not allow scrolling when synchronization is in progress.
                onlyOne ? AnyView(singleBattle) : AnyView(makeMultipleBattle(proxy: proxy))
            }
            .ignoresSafeArea()
            .overlay(
                LatestDataFloatButton(isPresent: $showFloatButton, action: {
                    if !onlyOne {
                        withAnimation {
                            proxy.scrollTo(viewModel.pages.first?.id)
                        }
                        showFloatButton = false
                    }
                }),
                alignment: .bottom
            )
            .onChange(of: synchronizeBattleViewModel.newMessage) { newValue in
                if newValue {
                    showFloatButton = true
                }
            }
        }
        .modifier(
            Popup(
                isPresented: showPlayerSkill,
                onDismiss: {
                    showPlayerSkill = false
                }, content: {
                    PlayerSkillView(
                        victory: $activePlayerVictory,
                        player: $activePlayer,
                        viewModel: avatarViewModel
                    ) {
                        showPlayerSkill = false
                    }
                }
            )
        )
        .navigationBarTitle(navigationTitle, displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if hidePlayerNames {
                        Button(action: {
                            hidePlayerNames = false
                        }) {
                            Label("Show Player Names", systemImage: "eye")
                        }
                    } else {
                        Button(action: {
                            hidePlayerNames = true
                        }) {
                            Label("Hide Player Names", systemImage: "eye.slash")
                        }
                    }
                }
                label: {
                    Label("Menu", systemImage: "ellipsis.circle")
                }
            }
        }
        .onDisappear {
            initPageId = viewModel.currentPageId ?? 0
        }
        .onChange(of: selectedRow) { row in
            viewModel.update(record: row.record, initPageId: initPageId, filterIndex: 0)
        }
    }

    var singleBattle: some View {
        Group {
            if let recordIndex = viewModel.recordIndex(with: initPageId) {
                let page = viewModel.pages[recordIndex]
                BattleDetailPage(
                    viewModel: page,
                    hidePlayerNames: hidePlayerNames,
                    showPlayerSkill: $showPlayerSkill,
                    hoveredMember: $hoveredMember,
                    activePlayer: $activePlayer,
                    activePlayerVictory: $activePlayerVictory
                )
                .id(page.record.id)
            } else {
                EmptyView()
            }
        }
        .background(AppColor.listBackgroundColor)
    }

    func makeMultipleBattle(proxy: ScrollViewProxy) -> some View {
        GeometryReader { geo in
            let pageWidth = geo.size.width
            ScrollViewOffset(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(viewModel.pages) { page in
                        // Wrapping BattleDetailPage with View is used to prevent
                        // the problem of the previous page not being released.
                        // It is caused by the Lazy Stack and the id() function working together.
                        // ZStack is used here, but it can be any View.
                        ZStack {
                            BattleDetailPage(
                                viewModel: page,
                                hidePlayerNames: hidePlayerNames,
                                showPlayerSkill: $showPlayerSkill,
                                hoveredMember: $hoveredMember,
                                activePlayer: $activePlayer,
                                activePlayerVictory: $activePlayerVictory
                            )
                        }
                        .frame(width: pageWidth, height: geo.size.height)
                        .id(page.id)
                    }
                }
            } onOffsetChange: { offset in
                let pageIndex = Int(round(offset.x / pageWidth))
                
                if !viewModel.pages.indices.contains(pageIndex) { return }
                guard let pageId = viewModel.pages[pageIndex].id else { return }
                if viewModel.pages[pageIndex].id == viewModel.currentPageId {
                    showFloatButton = false
                    return
                }

                viewModel.currentPageId = pageId
                showPage(pageId)
            }
            .scrollViewPaging()
            .onChange(of: initPageId) { pageId in
                showPlayerSkill = false
                proxy.scrollTo(pageId)
            }
            .onChange(of: selectedRow) { row in
                withAnimation {
                    proxy.scrollTo(row.id)
                }
            }
            .onAppear {
                withAnimation {
                    proxy.scrollTo(initPageId)
                }
            }
            .background(AppColor.listBackgroundColor)
        }
    }
}
