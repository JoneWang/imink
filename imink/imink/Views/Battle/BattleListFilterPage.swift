//
//  BattleListFilterPage.swift
//  imink
//
//  Created by Jone Wang on 2021/12/7.
//

import SwiftUI
import InkCore

struct NoHitTesting: ViewModifier {
    func body(content: Content) -> some View {
        SwiftUIWrapper { content }.allowsHitTesting(false)
    }
}

extension View {
    func userInteractionDisabled() -> some View {
        self.modifier(NoHitTesting())
    }
}

struct SwiftUIWrapper<T: View>: UIViewControllerRepresentable {
    let content: () -> T
    func makeUIViewController(context: Context) -> UIHostingController<T> {
        UIHostingController(rootView: content())
    }
    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {}
}

struct BattleListFilterPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject var viewModel: BattleListFilterViewModel
    
    @State private var customDate = Date()
    
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
                    }
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
        }
    }
    
    private func makeTimeFilterView(itemWidth: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text("时间")
                .font(.system(size: 20, weight: .bold))
            
            LazyVGrid(columns: Array(repeating: .init(.fixed(itemWidth), alignment: .leading), count: 3)) {
                ForEach(viewModel.dates, id: \.id) { item in
                    if item.id == .custom {
                        HStack(spacing: 0) {
                            Text(customDateTitle)
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture {
                                    if !item.canSelect { return }
                                    withAnimation {
                                        if viewModel.currentFilterContent.startDate == .custom {
                                            viewModel.currentFilterContent.startDate = nil
                                        } else {
                                            viewModel.currentFilterContent.startDate = .custom
                                        }
                                    }
                                }
                                .background(Color.quaternarySystemFill)
                                .opacity(item.canSelect ? 1 : 0.3)
                                .overlay(
                                    item.id == viewModel.currentFilterContent.startDate && item.canSelect ?
                                    AnyView(RoundedCorners(corners: [.topLeft, .bottomLeft], radius: cornerRadius)
                                                .stroke(Color.accentColor, lineWidth: 2).padding(0)) : AnyView(EmptyView())
                                )
                            
                            if item.canSelect {
                                Divider()
                            }
                            
                            ZStack {
                                GeometryReader { geo in
                                    DatePicker("", selection: $customDate, in: viewModel.customDateClosedRange, displayedComponents: [.date])
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .labelsHidden()
                                        .offset(x: geo.size.width / 2 - 30)
                                }
                                
                                Image(systemName: "calendar")
                                    .foregroundColor(.accentColor)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 2)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.quaternarySystemFill)
                                    .userInteractionDisabled()
                            }
                            .frame(width: 60)
                            .frame(maxHeight: .infinity)
                            .clipped()
                        }
                        .frame(width: itemWidth * 2 + itemSpacing, height: normalHeight)
                        .continuousCornerRadius(cornerRadius)
                    } else {
                        Text(item.id.name)
                            .font(.system(size: 15))
                            .frame(width: itemWidth, height: normalHeight)
                            .background(Color.quaternarySystemFill)
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
                ForEach(viewModel.battleTypes, id: \.id) { item in
                    Image(item.id.imageName)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(5)
                        .frame(width: itemWidth, height: itemHeight)
                        .background(Color.quaternarySystemFill)
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
                ForEach(viewModel.rules, id: \.id) { item in
                    Image(item.id.imageName, bundle: Bundle.inkCore)
                        .resizable()
                        .foregroundColor(.primary)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(5)
                        .frame(width: itemWidth, height: itemHeight)
                        .background(Color.quaternarySystemFill)
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
                    ForEach(viewModel.stages, id: \.id) { stage in
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
                    ForEach(viewModel.weapons, id: \.self) { weapon in
                        ImageView.weapon(id: weapon.id)
                            .padding(cornerRadius)
                            .background(Color.quaternarySystemFill)
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
