//
//  RealtimeRecordRow.swift
//  imink
//
//  Created by Jone Wang on 2020/9/18.
//

import SwiftUI

struct RealtimeRecordRow: View {
    @Binding var isLoading: Bool
    let record: Record
    let isSelected: Bool
    let onSelected: (Record) -> Void
    
    var body: some View {
        let contentView = HStack {
            Spacer()
            
            VStack {
                Spacer()
                
                Group {
                    if isLoading || record.battleNumber.isEmpty {
                        ProgressView()
                    } else {
                        Text("ID: \(record.battleNumber)")
                            .sp2Font(size: 20, color: Color.secondary)
                    }
                }
                .frame(height: 35)
                
                Spacer()
                
                Text("Real-time data")
                    .sp1Font(
                        size: 20,
                        color: isSelected ?
                            AppColor.recordRowTitleSelectedColor :
                            AppColor.recordRowTitleNormalColor
                    )
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(height: 90)
        .background(isSelected ? Color.accentColor : AppColor.battleListRowBackgroundColor)
        .cornerRadius(10)
        .onTapGesture {
            onSelected(record)
        }
        
        #if os(macOS)
        contentView
            .padding(.bottom)
        #else
        contentView
        #endif
    }
}

//struct RealtimeRecordRow_Previews: PreviewProvider {
//    static var previews: some View {
//        StatefulPreviewWrapper(true) {
//            RealtimeRecordRow(isLoading: $0, record: nil, isSelected: false)
//        }
//        StatefulPreviewWrapper(false) {
//            RealtimeRecordRow(isLoading: $0, record: nil, isSelected: true)
//        }
//    }
//}
