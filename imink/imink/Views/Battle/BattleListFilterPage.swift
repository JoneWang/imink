//
//  BattleListFilterPage.swift
//  imink
//
//  Created by Jone Wang on 2021/12/7.
//

import SwiftUI
import InkCore

fileprivate extension Battle.BattleType {
    static var filterKeys: [Battle.BattleType] {
        [.regular, .gachi, .league, .private, .fes]
    }
}

extension GameRule.Key {
    static var filterKeys: [GameRule.Key] {
        [.turfWar, .splatZones, .towerControl, .rainmaker, .clamBlitz]
    }
}

struct BattleListFilterPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject var viewModel = BattleListFilterViewModel()
    
    private let itemSpacing: CGFloat = 8
    private let threeColumn: CGFloat = 3
    private let fiveColumn: CGFloat = 5
    private let threeRow: Int = 3
    private let normalHeight: CGFloat = 35
    private let cornerRadius: CGFloat = 6
    
    @State private var selectedType: Battle.BattleType?
    @State private var selectedRule: GameRule.Key?
    @State private var selectedStageId: String?
    @State private var selectedWeaponId: String?
    
    private let onDone: (Battle.BattleType?, GameRule.Key?, String?, String?) -> Void
    
    init(
        type: Battle.BattleType?,
        rule: GameRule.Key?,
        stageId: String?,
        weaponId: String?,
        onDone: @escaping (Battle.BattleType?, GameRule.Key?, String?, String?) -> Void
    ) {
        self.onDone = onDone
        _selectedType = State(wrappedValue: type)
        _selectedRule = State(wrappedValue: rule)
        _selectedStageId = State(wrappedValue: stageId)
        _selectedWeaponId = State(wrappedValue: weaponId)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                let viewWidth = geo.size.width
                let threeColumnWidth = (viewWidth - (threeColumn - 1) * itemSpacing - 32) / threeColumn
                let fiveColumnWidth = (viewWidth - (fiveColumn - 1) * itemSpacing - 32) / fiveColumn
                
                if viewWidth > 0 {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 30) {
                            makeTimeFilterView(itemWidth: threeColumnWidth)
                                .padding(.horizontal, 16)
                            
                            makeTypeFilterView(itemWidth: fiveColumnWidth, itemHeight: normalHeight)
                                .padding(.horizontal, 16)
                            
                            makeRuleFilterView(itemWidth: fiveColumnWidth, itemHeight: normalHeight)
                                .padding(.horizontal, 16)
                            
                            makeStageFilterView(itemWidth: threeColumnWidth, itemHeight: normalHeight)
                            
                            makeWeaponFilterView(itemWidth: fiveColumnWidth)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationBarTitle("筛选", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    selectedType = nil
                    selectedRule = nil
                    selectedStageId = nil
                    selectedWeaponId = nil
                }) {
                    Text("重置")
                        .foregroundColor(.accentColor)
                        .frame(height: 40)
                },
                trailing: Button(action: {
                    onDone(selectedType, selectedRule, selectedStageId, selectedWeaponId)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("完成")
                        .foregroundColor(.accentColor)
                        .frame(height: 40)
                }
            )
        }
    }
    
    private func makeTimeFilterView(itemWidth: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text("时间")
                .font(.system(size: 20, weight: .bold))
            
            HStack(alignment: .center) {
                Text("今日")
                    .font(.system(size: 15))
                    .frame(height: normalHeight)
                    .frame(maxWidth: .infinity)
                    .background(Color.quaternarySystemFill)
                    .continuousCornerRadius(cornerRadius)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: cornerRadius)
//                            .stroke(Color.accentColor, lineWidth: 1)
//                    )
                
                Text("7天")
                    .font(.system(size: 15))
                    .frame(height: normalHeight)
                    .frame(maxWidth: .infinity)
                    .background(Color.quaternarySystemFill)
                    .continuousCornerRadius(cornerRadius)
                
                Text("30天")
                    .font(.system(size: 15))
                    .frame(height: normalHeight)
                    .frame(maxWidth: .infinity)
                    .background(Color.quaternarySystemFill)
                    .continuousCornerRadius(cornerRadius)
            }
            
            HStack(alignment: .center) {
                Text("3个月")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
                    .frame(width: itemWidth, height: normalHeight)
                    .background(Color.quaternarySystemFill)
                    .continuousCornerRadius(cornerRadius)
                
                Text("2021-12-01 ~ 2022-01-01")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
                    .frame(height: normalHeight)
                    .background(Color.quaternarySystemFill)
                    .continuousCornerRadius(cornerRadius)
            }
        }
    }
    
    private func makeTypeFilterView(itemWidth: CGFloat, itemHeight: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text("模式")
                .font(.system(size: 20, weight: .bold))
            
            HStack {
                ForEach(Battle.BattleType.filterKeys, id: \.self) { type in
                    Image(type.imageName)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(5)
                        .frame(width: itemWidth, height: itemHeight)
                        .background(Color.quaternarySystemFill)
                        .continuousCornerRadius(cornerRadius)
                        .overlay(
                            type == selectedType ?
                            AnyView(RoundedRectangle(cornerRadius: cornerRadius)
                                        .strokeBorder(Color.accentColor, lineWidth: 1).padding(0)) : AnyView(EmptyView())
                        )
                        .onTapGesture {
                            if selectedType != type {
                                selectedType = type
                            } else {
                                selectedType = nil
                            }
                        }
                }
            }
        }
    }
    
    private func makeRuleFilterView(itemWidth: CGFloat, itemHeight: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text("规则")
                .font(.system(size: 20, weight: .bold))
            
            HStack {
                ForEach(GameRule.Key.filterKeys, id: \.self) { rule in
                    Image(rule.imageName, bundle: Bundle.inkCore)
                        .resizable()
                        .foregroundColor(.primary)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(5)
                        .frame(width: itemWidth, height: itemHeight)
                        .background(Color.quaternarySystemFill)
                        .continuousCornerRadius(cornerRadius)
                        .overlay(
                            rule == selectedRule ?
                            AnyView(RoundedRectangle(cornerRadius: cornerRadius)
                                        .strokeBorder(Color.accentColor, lineWidth: 1).padding(0)) : AnyView(EmptyView())
                        )
                        .onTapGesture {
                            if selectedRule != rule {
                                selectedRule = rule
                            } else {
                                selectedRule = nil
                            }
                        }
                }
            }
        }
    }
    
    private func makeStageFilterView(itemWidth: CGFloat, itemHeight: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text("场地")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(0...viewModel.stages.count/threeRow, id: \.self) { column in
                        VStack {
                            ForEach(0..<threeRow) { row in
                                let index = (column as Int) * threeRow + row
                                if index < viewModel.stages.count {
                                    let stage = viewModel.stages[index]
                                    ImageView.stage(id: stage.id)
                                        .aspectRatio(640 / 360, contentMode: .fill)
                                        .frame(width: itemWidth, height: itemHeight)
                                        .continuousCornerRadius(cornerRadius)
                                        .opacity(stage.canSelect ? 1 : 0.3)
                                        .overlay(
                                            stage.id == selectedStageId ?
                                            AnyView(RoundedRectangle(cornerRadius: cornerRadius)
                                                        .strokeBorder(Color.accentColor, lineWidth: 1).padding(0)) : AnyView(EmptyView())
                                        )
                                        .onTapGesture {
                                            if !stage.canSelect { return }
                                            if selectedStageId != stage.id {
                                                selectedStageId = stage.id
                                            } else {
                                                selectedStageId = nil
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private func makeWeaponFilterView(itemWidth: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text("武器")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 16)
        
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(0...viewModel.weapons.count/threeRow, id: \.self) { column in
                        VStack {
                            ForEach(0..<threeRow) { row in
                                let index = (column as Int) * threeRow + row
                                if index < viewModel.weapons.count {
                                    let weapon = viewModel.weapons[index]
                                    ImageView.weapon(id: weapon.id)
                                        .padding(cornerRadius)
                                        .background(Color.quaternarySystemFill)
                                        .frame(width: itemWidth, height: itemWidth)
                                        .continuousCornerRadius(cornerRadius)
                                        .opacity(weapon.canSelect ? 1 : 0.3)
                                        .overlay(
                                            weapon.id == selectedWeaponId ?
                                            AnyView(RoundedRectangle(cornerRadius: cornerRadius)
                                                        .strokeBorder(Color.accentColor, lineWidth: 1).padding(0)) : AnyView(EmptyView())
                                        )
                                        .onTapGesture {
                                            if !weapon.canSelect { return }
                                            if selectedWeaponId != weapon.id {
                                                selectedWeaponId = weapon.id
                                            } else {
                                                selectedWeaponId = nil
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct BattleListFilterPage_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) { show in
            VStack { }
                .sheet(isPresented: show) {
                    HalfSheet {
                        BattleListFilterPage(type: nil, rule: nil, stageId: nil, weaponId: nil) { _, _, _, _ in }
                        .preferredColorScheme(.dark)
                    }
                }
        }
        .preferredColorScheme(.dark)
    }
}

class HalfSheetController<Content>: UIHostingController<Content> where Content : View {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 15.0, *) {
            if let presentation = sheetPresentationController {
                // configure at will
                presentation.prefersScrollingExpandsWhenScrolledToEdge = false
                presentation.detents = [.medium(), .large()]
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct HalfSheet<Content>: UIViewControllerRepresentable where Content : View {
    private let content: Content
    
    @inlinable init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> HalfSheetController<Content> {
        return HalfSheetController(rootView: content)
    }
    
    func updateUIViewController(_: HalfSheetController<Content>, context: Context) {

    }
}
