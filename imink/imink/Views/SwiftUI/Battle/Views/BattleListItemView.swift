//
//  BattleListItemView.swift
//  imink
//
//  Created by Jone Wang on 2021/2/8.
//

import SwiftUI
import InkCore

struct BattleListItemView: View {
    
    static let RealtimeRecordId: Int64 = -1
    
    let row: BattleListRowModel
    @Binding var selectedId: String?
    
    @State private var isSelected: Bool = false
    @State private var realtimeLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if row.type == .realtime {
                makeRealtimeContent()
                    .padding(.top, 16)
                    .padding(.bottom)
                    .padding([.leading, .trailing], 8)
                    .background(isSelected ? .systemGray5 : AppColor.listItemBackgroundColor)
                    .frame(height: 79)
                    .continuousCornerRadius(10)
                    .onReceive(
                        NotificationCenter.default
                            .publisher(for: .isLoadingRealTimeBattleResult)
                            .map { $0.object as! Bool },
                        perform: { self.realtimeLoading = $0 }
                    )
            } else if let record = row.record {
                makeRecordContent(record: record)
                    .padding(.top, 7.5)
                    .padding(.bottom, 7)
                    .padding([.leading, .trailing], 8)
                    .background(isSelected ? .systemGray5 : AppColor.listItemBackgroundColor)
                    .frame(height: 79)
                    .continuousCornerRadius(10)
            }
        }
        .onChange(of: selectedId) { value in
            withAnimation {
                self.isSelected = selectedId == row.id
            }
        }
    }
    
    func makeRealtimeContent() -> some View {
        HStack {
            Spacer()
            
            VStack(spacing: 8) {
                if let battleNumber = row.record?.battleNumber, !realtimeLoading {
                    Text("ID: \(battleNumber)")
                        .sp1Font(size: 18, color: Color.secondaryLabel)
                        .frame(height: 24)
                } else {
                    ProgressView()
                        .scaleEffect(1.3)
                        .frame(height: 24)
                }
                
                Text("Real-time data")
                    .sp1Font(size: 18, color: AppColor.appLabelColor)
            }
            
            Spacer()
        }
    }
    
    func makeRecordContent(record: DBRecord) -> some View {
        let gameMode = GameMode.Key(rawValue: record.gameModeKey)!
        
        return ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    Image(record.gameModeImageName)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(.top, -0.5)
                        .padding(.bottom, -1.5)
                    
                    Text(record.rule.localizedKey)
                        .sp1Font(size: 12, color: record.gameModeColor)
                    
                    Spacer()
                    
                    if gameMode == .gachi ||
                        gameMode == .leaguePair ||
                        gameMode == .leagueTeam {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text(record.udemaeName ?? "C-")
                                .sp1Font(size: 12, color: AppColor.appLabelColor)
                            
                            if let sPlusNumber = record.udemaeSPlusNumber {
                                Text("\(sPlusNumber)")
                                    .sp1Font(size: 8, color: AppColor.spGreenLimeColor)
                                    .padding(.leading, 0.6)
                                    .padding(.bottom, 0)
                            }
                        }
                    }
                }
                .padding(.bottom, 6.5)
                
                HStack {
                    Text(record.victory ? "VICTORY" : "DEFEAT")
                        .sp1Font(size: 14, color: record.resultColor)
                    
                    Spacer()
                    
                    HStack {
                        let speciesName = record.playerTypeSpecies == .inklings ? "Ika" : "Tako"
                        
                        HStack(spacing: 3) {
                            Image("\(speciesName)_k")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.systemGray3)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text("\(record.killCount + record.assistCount)")
                                    .sp2Font(size: 10, color: AppColor.appLabelColor)
                                Text(" (\(record.assistCount))")
                                    .sp2Font(size: 7, color: AppColor.appLabelColor)
                            }
                        }
                        
                        HStack(spacing: 3) {
                            Image("\(speciesName)_d")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.systemGray3)
                            
                            Text("\(record.deathCount)")
                                .sp2Font(size: 10, color: AppColor.appLabelColor)
                        }
                        
                        HStack(spacing: 3) {
                            Image("\(speciesName)_kd")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.systemGray3)
                            
                            Text("\(Double(record.killCount) -/ Double(record.deathCount), places: 1)")
                                .sp2Font(size: 10, color: AppColor.appLabelColor)
                        }
                    }
                }
                .padding(.bottom, 7)
                
                HStack(spacing: 0) {
                    GeometryReader { geo in
                        Rectangle()
                            .foregroundColor(Color.systemGray3)
                        
                        Rectangle()
                            .foregroundColor(record.resultColor)
                            .frame(width: geo.size.width * CGFloat(record.myPoint &/ (record.myPoint + record.otherPoint)))
                    }
                }
                .frame(height: 5)
                .clipShape(Capsule())
                .padding(.bottom, 6)
                
                HStack {
                    Text("#\(record.battleNumber) · \(record.stageName.localized)")
                        .font(.system(size: 10))
                        .foregroundColor(.systemGray2)
                    
                    Spacer()
                    
                    Text(record.powerText)
                        .font(.system(size: 10))
                        .foregroundColor(.systemGray2)
                }
            }
            
            VStack {
                WeaponImageView(
                    id: record.weaponId,
                    imageURL: record.weaponImageURL
                )
                .frame(width: 40, height: 40)
                
                Spacer()
            }
            .padding(.top, 6.5)
        }
    }
}

extension DBRecord {
    
    var resultColor: Color {
        victory ?
            AppColor.spPink :
            AppColor.spLightGreen
    }
    
    var gameModeImageName: String {
        switch gameModeKey {
        case "regular":
            return "RegularBattle"
        case "gachi":
            return "RankedBattle"
        case "league_pair", "league_team":
            return "LeagueBattle"
        case "fes_team", "fes_solo":
            return "SplatfestBattle"
        case "private":
            return "PrivateBattle"
        default:
            return ""
        }
    }
    
    var gameModeColor: Color {
        switch gameModeKey {
        case "regular":
            return AppColor.spLightGreen
        case "gachi":
            return AppColor.spOrange
        case "league_pair", "league_team":
            return AppColor.spPink
        case "fes_team", "fes_solo":
            return AppColor.spYellow
        case "private":
            return AppColor.spPurple
        default:
            return AppColor.appLabelColor
        }
    }
    
    var powerText: String {
        let gameMode = GameMode.Key(rawValue: gameModeKey)!
        
        if gameMode == .leaguePair || gameMode == .leagueTeam {
            if let power = leaguePoint, power > 0 {
                return String(format: "%@ power".localized, "\(power, places: 0)")
            } else {
                return String(format: "%@ power".localized, "---")
            }
        } else if gameMode == .gachi {
            if isX {
                if let power = xPower, power > 0 {
                    return String(format: "%@ power".localized, "\(power, places: 0)")
                } else {
                    return String(format: "%@ power".localized, "---")
                }
            } else if let power = estimateGachiPower {
                return String(format: "%@ power".localized, "\(power)")
            }
        }
        
        return ""
    }
}

struct BattleListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let dbRecord = DBRecord(
            battleNumber: "12345",
            victory: true,
            weaponId: "11",
            weaponImage: "",
            rule: "Turf War",
            gameMode: "Regular",
            gameModeKey: "gachi",
            stageName: "Arowana Mall",
            killTotalCount: 10,
            killCount: 6,
            assistCount: 2,
            specialCount: 2,
            gamePaintPoint: 1300,
            deathCount: 5,
            myPoint: 38,
            otherPoint: 50,
            syncDetailTime: Date(),
            startDateTime: Date(),
            udemaeName: "S+",
            udemaeSPlusNumber: 0,
            type: .regular,
            leaguePoint: 1234.0,
            estimateGachiPower: 1234,
            playerTypeSpecies: .inklings,
            isX: false,
            xPower: 0
        )
        let realtimeRow = BattleListRowModel(type: .realtime, record: dbRecord)
        let row = BattleListRowModel(type: .record, record: dbRecord)
        
        StatefulPreviewWrapper("") { selectedId in
            BattleListItemView(row: realtimeRow, selectedId: selectedId)
                .padding(.top, 8)
                .padding([.leading, .trailing])
                .background(AppColor.listBackgroundColor)
                .previewLayout(.sizeThatFits)
        }
        
        StatefulPreviewWrapper("") { selectedId in
            BattleListItemView(row: row, selectedId: selectedId)
                .padding(.top, 8)
                .padding([.leading, .trailing])
                .background(AppColor.listBackgroundColor)
                .previewLayout(.sizeThatFits)
        }
            
        StatefulPreviewWrapper("") { selectedId in
            BattleListItemView(row: row, selectedId: selectedId)
                .padding(.top, 8)
                .padding([.leading, .trailing])
                .background(AppColor.listBackgroundColor)
                .previewLayout(.sizeThatFits)
                .colorScheme(.dark)
        }
    }
}
