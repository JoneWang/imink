//
//  BattleListPage.swift
//  imink
//
//  Created by Jone Wang on 2021/2/8.
//

import SwiftUI
import InkCore

struct BattleListPage: View {
    @EnvironmentObject var mainViewModel: MainViewModel
        
    @StateObject var viewModel = BattleListViewModel()
    
    @State var showFilter: Bool = false
    
    @State private var rows: [BattleListRowModel] = []
    
    var body: some View {
        if viewModel.isLogined {
            content
                .navigationViewStyle(.automatic)
        } else {
            content
                .navigationViewStyle(.stack)
        }
    }
    
    var content: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVStack {
                        if !viewModel.filterContent.noContent {
                            // TODO: Stat
                            VStack{
                                HStack {
                                    if let battleType = viewModel.filterContent.battleType {
                                        Image(battleType.imageName)
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(.primary)
                                            .aspectRatio(1, contentMode: .fit)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .frame(height: 30)
                                            .background(Color.quaternarySystemFill)
                                            .continuousCornerRadius(6)
                                    }
                                    if let rule = viewModel.filterContent.rule {
                                        Image(rule.imageName, bundle: Bundle.inkCore)
                                            .resizable()
                                            .foregroundColor(.primary)
                                            .aspectRatio(1, contentMode: .fit)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .frame(height: 30)
                                            .background(Color.quaternarySystemFill)
                                            .continuousCornerRadius(6)
                                    }
                                    if let stageId = viewModel.filterContent.stageId {
                                        ImageView.stage(id: stageId)
                                            .aspectRatio(640 / 360, contentMode: .fit)
                                            .frame(height: 30)
                                            .background(Color.quaternarySystemFill)
                                            .continuousCornerRadius(6)
                                    }
                                    if let weaponId = viewModel.filterContent.weaponId {
                                        ImageView.weapon(id: weaponId)
                                            .aspectRatio(1, contentMode: .fit)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .frame(height: 30)
                                            .background(Color.quaternarySystemFill)
                                            .continuousCornerRadius(6)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 16)
                            .padding(.bottom)
                            .padding([.leading, .trailing], 8)
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .background(AppColor.listItemBackgroundColor)
                            .continuousCornerRadius(10)
                            .padding([.leading, .trailing])
                        }

                        ForEach(rows, id: \.id) { row in
                            BattleListItemView(
                                row: row,
                                selectedId: $viewModel.selectedId
                            )
                            .padding([.leading, .trailing])
                            .onTapGesture {
                                self.viewModel.selectedId = row.id
                            }
                            .background(
                                NavigationLink(
                                    destination: BattleDetailPage(
                                        row: row,
                                        realtimeRow: $viewModel.realtimeRow
                                    ),
                                    tag: row.id,
                                    selection: $viewModel.selectedId
                                ) { EmptyView() }
                                .buttonStyle(PlainButtonStyle())
                            )
                        }
                    }
                    .padding([.top, .bottom], 16)
                }
            }
            .fixSafeareaBackground()
            .modifier(LoginViewModifier(isLogined: viewModel.isLogined, iconName: "TabBarBattle"))
            .navigationBarTitle("Battles", displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarItems(trailing: makeBarRightItem())
        }
        .sheet(isPresented: $showFilter) {
            BattleListFilterPage(
                viewModel.filterContent
            ) { filterContent in
                viewModel.filterContent = filterContent
            }
        }
        .onReceive(mainViewModel.$isLogined) { isLogined in
            viewModel.updateLoginStatus(isLogined: isLogined)
        }
        .onChange(of: viewModel.rows) { rows in
            withAnimation {
                self.rows = rows
            }
        }
        .onAppear {
            self.rows = viewModel.rows
        }
    }
    
    private func makeBarRightItem() -> some View {
        if viewModel.isLogined {
            return AnyView(Button(action: {
                showFilter = true
            }) {
                HStack {
                    Spacer()
                    
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .frame(width: 22, height: 22)
                }
                .frame(width: 38, height: 40)
            })
        }
        
        return AnyView(EmptyView())
    }
}

struct BattleListPage_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BattleListViewModel()
        BattleListPage(viewModel: viewModel)
    }
}
