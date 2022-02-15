//
//  BattleListFilterPage.swift
//  imink
//
//  Created by Jone Wang on 2021/12/7.
//

import SwiftUI
import InkCore
import Popovers

struct BattleListFilterPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject var viewModel: BattleListFilterViewModel
    
    @State private var dates: [BattleListFilterViewModel.DateFilterItem] = []
    @State private var battleTypes: [BattleListFilterViewModel.BattleTypeFilterItem] = []
    @State private var rules: [BattleListFilterViewModel.RuleFilterItem] = []
    @State private var stages: [BattleListFilterViewModel.ObjectIdFilterItem] = []
    @State private var weapons: [BattleListFilterViewModel.ObjectIdFilterItem] = []
    @State private var customDate: Date
    @State private var showDatePicker = false
    
    private let itemSpacing: CGFloat = 8
    private let threeColumn: CGFloat = 3
    private let fiveColumn: CGFloat = 5
    private let threeRow: Int = 3
    private let normalHeight: CGFloat = 35
    private let cornerRadius: CGFloat = 6
    
    private let onDone: (BattleListFilterContent) -> Void
    
    private var customDateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: viewModel.currentFilterContent.customDate)
    }
    
    init(
        _ filterContent: BattleListFilterContent,
        onDone: @escaping (BattleListFilterContent) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: BattleListFilterViewModel(filterContent))
        _customDate = State(wrappedValue: _viewModel.wrappedValue.currentFilterContent.customDate)
        
        self.onDone = onDone
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
                        .padding(.bottom, UIApplication.shared.windows.first!.safeAreaInsets.bottom)
                    }
                    .background(AppColor.listBackgroundColor)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationBarTitle("筛选", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    viewModel.currentFilterContent = BattleListFilterContent()
                    onDone(viewModel.currentFilterContent)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("重置")
                        .foregroundColor(.accentColor)
                        .frame(height: 40)
                },
                trailing: Button(action: {
                    onDone(viewModel.currentFilterContent)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("完成")
                        .foregroundColor(.accentColor)
                        .frame(height: 40)
                }
            )
            .onChange(of: customDate) { newValue in
                viewModel.currentFilterContent.customDate = newValue
            }
            .onReceive(viewModel.$dates) { newValue in
                withAnimation { dates = newValue }
            }
            .onReceive(viewModel.$battleTypes) { newValue in
                withAnimation { battleTypes = newValue }
            }
            .onReceive(viewModel.$rules) { newValue in
                withAnimation { rules = newValue }
            }
            .onReceive(viewModel.$stages) { newValue in
                withAnimation { stages = newValue }
            }
            .onReceive(viewModel.$weapons) { newValue in
                withAnimation { weapons = newValue }
            }
        }
    }
    
    private func makeTimeFilterView(itemWidth: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text("时间")
                .font(.system(size: 20, weight: .bold))
            
            LazyVGrid(columns: Array(repeating: .init(.fixed(itemWidth), alignment: .leading), count: 3)) {
                ForEach(dates, id: \.id) { item in
                    if item.id == .custom {
                        HStack(spacing: 8) {
                            Spacer()
                            
                            Text(item.id == viewModel.currentFilterContent.startDate ? customDateTitle : "Custom")
                                .font(.system(size: 15))
                            
                            Image(systemName: "calendar")
                            
                            Spacer()
                        }
                        .frame(width: itemWidth * 2 + itemSpacing, height: normalHeight)
                        .background(AppColor.listItemBackgroundColor)
                        .overlay(
                            item.id == viewModel.currentFilterContent.startDate && item.canSelect ?
                            AnyView(RoundedRectangle(cornerRadius: cornerRadius)
                                        .strokeBorder(Color.accentColor, lineWidth: 1).padding(0)) : AnyView(EmptyView())
                        )
                        .continuousCornerRadius(cornerRadius)
                        .onTapGesture {
                            if item.id == viewModel.currentFilterContent.startDate {
                                withAnimation {
                                    viewModel.currentFilterContent.startDate = nil
                                }
                            } else {
                                showDatePicker = true
                            }
                        }
                        .popover(
                            present: $showDatePicker,
                            attributes: {
                                $0.rubberBandingMode = .none
                                $0.sourceFrameInset.bottom = -8
                                $0.blocksBackgroundTouches = true
                                $0.onTapOutside = {
                                    showDatePicker = false
                                }
                            }
                        ) {
                            PopoverTemplates.Standard {
                                DatePicker("", selection: $customDate, in: viewModel.customDateClosedRange, displayedComponents: [.date])
                                    .datePickerStyle(.graphical)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .onChange(of: customDate) { newValue in
                            withAnimation {
                                viewModel.currentFilterContent.startDate = .custom
                            }
                        }
                    } else {
                        Text(item.id.name)
                            .font(.system(size: 15))
                            .frame(width: itemWidth, height: normalHeight)
                            .background(AppColor.listItemBackgroundColor)
                            .continuousCornerRadius(cornerRadius)
                            .opacity(item.canSelect ? 1 : 0.3)
                            .overlay(
                                item.id == viewModel.currentFilterContent.startDate ?
                                AnyView(RoundedRectangle(cornerRadius: cornerRadius)
                                            .strokeBorder(Color.accentColor, lineWidth: 1).padding(0)) : AnyView(EmptyView())
                            )
                            .onTapGesture {
                                if !item.canSelect { return }
                                withAnimation {
                                    if viewModel.currentFilterContent.startDate != item.id {
                                        viewModel.currentFilterContent.startDate = item.id
                                    } else {
                                        viewModel.currentFilterContent.startDate = nil
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
    
    private func makeTypeFilterView(itemWidth: CGFloat, itemHeight: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text("模式")
                .font(.system(size: 20, weight: .bold))
            
            HStack {
                ForEach(battleTypes, id: \.id) { item in
                    Image(item.id.imageName)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(5)
                        .frame(width: itemWidth, height: itemHeight)
                        .background(AppColor.listItemBackgroundColor)
                        .continuousCornerRadius(cornerRadius)
                        .opacity(item.canSelect ? 1 : 0.3)
                        .overlay(
                            item.id == viewModel.currentFilterContent.battleType ?
                            AnyView(RoundedRectangle(cornerRadius: cornerRadius)
                                        .strokeBorder(Color.accentColor, lineWidth: 1).padding(0)) : AnyView(EmptyView())
                        )
                        .onTapGesture {
                            if !item.canSelect { return }
                            withAnimation {
                                if viewModel.currentFilterContent.battleType != item.id {
                                    viewModel.currentFilterContent.battleType = item.id
                                } else {
                                    viewModel.currentFilterContent.battleType = nil
                                }
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
                ForEach(rules, id: \.id) { item in
                    Image(item.id.imageName, bundle: Bundle.inkCore)
                        .resizable()
                        .foregroundColor(.primary)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(5)
                        .frame(width: itemWidth, height: itemHeight)
                        .background(AppColor.listItemBackgroundColor)
                        .continuousCornerRadius(cornerRadius)
                        .opacity(item.canSelect ? 1 : 0.3)
                        .overlay(
                            item.id == viewModel.currentFilterContent.rule ?
                            AnyView(RoundedRectangle(cornerRadius: cornerRadius)
                                        .strokeBorder(Color.accentColor, lineWidth: 1).padding(0)) : AnyView(EmptyView())
                        )
                        .onTapGesture {
                            if !item.canSelect { return }
                            withAnimation {
                                if viewModel.currentFilterContent.rule != item.id {
                                    viewModel.currentFilterContent.rule = item.id
                                } else {
                                    viewModel.currentFilterContent.rule = nil
                                }
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
                LazyHGrid(rows: Array(repeating: .init(.fixed(itemHeight)), count: 3)) {
                    ForEach(stages, id: \.id) { stage in
                        ImageView.stage(id: stage.id)
                            .aspectRatio(640 / 360, contentMode: .fill)
                            .frame(width: itemWidth, height: itemHeight)
                            .continuousCornerRadius(cornerRadius)
                            .opacity(stage.canSelect ? 1 : 0.3)
                            .overlay(
                                stage.id == viewModel.currentFilterContent.stageId ?
                                AnyView(RoundedRectangle(cornerRadius: cornerRadius)
                                            .strokeBorder(Color.accentColor, lineWidth: 1).padding(0)) : AnyView(EmptyView())
                            )
                            .onTapGesture {
                                if !stage.canSelect { return }
                                withAnimation {
                                    if viewModel.currentFilterContent.stageId != stage.id {
                                        viewModel.currentFilterContent.stageId = stage.id
                                    } else {
                                        viewModel.currentFilterContent.stageId = nil
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
        return VStack(alignment: .leading) {
            Text("武器")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: Array(repeating: .init(.fixed(itemWidth)), count: 3)) {
                    ForEach(weapons, id: \.self) { weapon in
                        ImageView.weapon(id: weapon.id)
                            .padding(cornerRadius)
                            .background(AppColor.listItemBackgroundColor)
                            .frame(width: itemWidth, height: itemWidth)
                            .continuousCornerRadius(cornerRadius)
                            .opacity(weapon.canSelect ? 1 : 0.3)
                            .overlay(
                                weapon.id == viewModel.currentFilterContent.weaponId ?
                                AnyView(RoundedRectangle(cornerRadius: cornerRadius)
                                            .strokeBorder(Color.accentColor, lineWidth: 1).padding(0)) : AnyView(EmptyView())
                            )
                            .onTapGesture {
                                if !weapon.canSelect { return }
                                withAnimation {
                                    if viewModel.currentFilterContent.weaponId != weapon.id {
                                        viewModel.currentFilterContent.weaponId = weapon.id
                                    } else {
                                        viewModel.currentFilterContent.weaponId = nil
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
                    BattleListFilterPage(BattleListFilterContent()) { _ in }
                        .preferredColorScheme(.dark)
                }
        }
        .preferredColorScheme(.dark)
    }
}

fileprivate extension BattleListFilterViewModel.FilterDate {
    var name: String {
        switch self {
        case .sevenDays:
            return "7天"
        case .oneMonth:
            return "一个月"
        case .threeMonth:
            return "三个月"
        case .oneYear:
            return "一年"
        case .custom:
            return "自定义"
        }
    }
}
