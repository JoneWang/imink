//
//  BubbleView.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/11/29.
//

import SwiftUI
import WidgetKit

struct BubbleView : View {
    let size: CGSize
    var add: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let rows = (Int)(ceil(size.height / BubbleTile.tileSize.height)) + add
            
            ForEach((0..<rows).indices) { _ in
                HStack(alignment: .top, spacing: 0) {
                    let columns = (Int)(ceil(size.width / BubbleTile.tileSize.width)) + add
                    
                    ForEach((0..<columns).indices) { _ in
                        BubbleTile()
                            .frame(width: BubbleTile.tileSize.width, height: BubbleTile.tileSize.height)
                            .clipped()
                    }
                }
            }
        }
    }
}

struct BubbleTile: Shape {
    static let tileSize = CGSize(width: 241, height: 120.5)
    
    func path(in rect: CGRect) -> Path{
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        path.move(to: CGPoint(x: 0.02344*width, y: 0.1875*height))
        path.addCurve(to: CGPoint(x: 0.0918*width, y: 0.09766*height),control1: CGPoint(x: 0.05903*width, y: 0.1875*height),control2: CGPoint(x: 0.0918*width, y: 0.16797*height))
        path.addCurve(to: CGPoint(x: 0, y: -0.05859*height),control1: CGPoint(x: 0.0918*width, y: 0.02734*height),control2: CGPoint(x: 0.03906*width, y: -0.05078*height))
        path.addCurve(to: CGPoint(x: -0.08203*width, y: 0.03906*height),control1: CGPoint(x: -0.03906*width, y: -0.06641*height),control2: CGPoint(x: -0.08203*width, y: -0.04297*height))
        path.addCurve(to: CGPoint(x: -0.05078*width, y: 0.15234*height),control1: CGPoint(x: -0.08203*width, y: 0.07835*height),control2: CGPoint(x: -0.07139*width, y: 0.1258*height))
        path.addCurve(to: CGPoint(x: 0.02344*width, y: 0.1875*height),control1: CGPoint(x: -0.02835*width, y: 0.18122*height),control2: CGPoint(x: 0.00489*width, y: 0.1875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 1.02344*width, y: 0.18751*height))
        path.addCurve(to: CGPoint(x: 1.0918*width, y: 0.09767*height),control1: CGPoint(x: 1.05903*width, y: 0.18751*height),control2: CGPoint(x: 1.0918*width, y: 0.16798*height))
        path.addCurve(to: CGPoint(x: width, y: -0.05858*height),control1: CGPoint(x: 1.0918*width, y: 0.02735*height),control2: CGPoint(x: 1.03906*width, y: -0.05077*height))
        path.addCurve(to: CGPoint(x: 0.91797*width, y: 0.03907*height),control1: CGPoint(x: 0.96094*width, y: -0.0664*height),control2: CGPoint(x: 0.91797*width, y: -0.04296*height))
        path.addCurve(to: CGPoint(x: 0.94922*width, y: 0.15235*height),control1: CGPoint(x: 0.91797*width, y: 0.07836*height),control2: CGPoint(x: 0.92861*width, y: 0.12581*height))
        path.addCurve(to: CGPoint(x: 1.02344*width, y: 0.18751*height),control1: CGPoint(x: 0.97165*width, y: 0.18123*height),control2: CGPoint(x: 1.00489*width, y: 0.18751*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.02344*width, y: 1.18751*height))
        path.addCurve(to: CGPoint(x: 0.0918*width, y: 1.09767*height),control1: CGPoint(x: 0.05903*width, y: 1.18751*height),control2: CGPoint(x: 0.0918*width, y: 1.16798*height))
        path.addCurve(to: CGPoint(x: 0, y: 0.94142*height),control1: CGPoint(x: 0.0918*width, y: 1.02735*height),control2: CGPoint(x: 0.03906*width, y: 0.94923*height))
        path.addCurve(to: CGPoint(x: -0.08203*width, y: 1.03907*height),control1: CGPoint(x: -0.03906*width, y: 0.9336*height),control2: CGPoint(x: -0.08203*width, y: 0.95704*height))
        path.addCurve(to: CGPoint(x: -0.05078*width, y: 1.15235*height),control1: CGPoint(x: -0.08203*width, y: 1.07836*height),control2: CGPoint(x: -0.07139*width, y: 1.12581*height))
        path.addCurve(to: CGPoint(x: 0.02344*width, y: 1.18751*height),control1: CGPoint(x: -0.02835*width, y: 1.18123*height),control2: CGPoint(x: 0.00489*width, y: 1.18751*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 1.02344*width, y: 1.18751*height))
        path.addCurve(to: CGPoint(x: 1.0918*width, y: 1.09767*height),control1: CGPoint(x: 1.05903*width, y: 1.18751*height),control2: CGPoint(x: 1.0918*width, y: 1.16798*height))
        path.addCurve(to: CGPoint(x: width, y: 0.94142*height),control1: CGPoint(x: 1.0918*width, y: 1.02735*height),control2: CGPoint(x: 1.03906*width, y: 0.94923*height))
        path.addCurve(to: CGPoint(x: 0.91797*width, y: 1.03907*height),control1: CGPoint(x: 0.96094*width, y: 0.9336*height),control2: CGPoint(x: 0.91797*width, y: 0.95704*height))
        path.addCurve(to: CGPoint(x: 0.94922*width, y: 1.15235*height),control1: CGPoint(x: 0.91797*width, y: 1.07836*height),control2: CGPoint(x: 0.92861*width, y: 1.12581*height))
        path.addCurve(to: CGPoint(x: 1.02344*width, y: 1.18751*height),control1: CGPoint(x: 0.97165*width, y: 1.18123*height),control2: CGPoint(x: 1.00489*width, y: 1.18751*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.91797*width, y: 0.3125*height))
        path.addCurve(to: CGPoint(x: 0.97266*width, y: 0.21484*height),control1: CGPoint(x: 0.94922*width, y: 0.3125*height),control2: CGPoint(x: 0.97266*width, y: 0.26878*height))
        path.addCurve(to: CGPoint(x: 0.91797*width, y: 0.125*height),control1: CGPoint(x: 0.97266*width, y: 0.16091*height),control2: CGPoint(x: 0.95117*width, y: 0.125*height))
        path.addCurve(to: CGPoint(x: 0.86133*width, y: 0.22266*height),control1: CGPoint(x: 0.88477*width, y: 0.125*height),control2: CGPoint(x: 0.86133*width, y: 0.17188*height))
        path.addCurve(to: CGPoint(x: 0.91797*width, y: 0.3125*height),control1: CGPoint(x: 0.86133*width, y: 0.27344*height),control2: CGPoint(x: 0.88672*width, y: 0.3125*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: -0.06641*width, y: 0.86719*height))
        path.addCurve(to: CGPoint(x: 0.05273*width, y: 0.64844*height),control1: CGPoint(x: -0.006*width, y: 0.86719*height),control2: CGPoint(x: 0.05273*width, y: 0.79688*height))
        path.addCurve(to: CGPoint(x: -0.06055*width, y: 0.41797*height),control1: CGPoint(x: 0.05273*width, y: 0.5*height),control2: CGPoint(x: -0.00014*width, y: 0.41797*height))
        path.addCurve(to: CGPoint(x: -0.19922*width, y: 0.61719*height),control1: CGPoint(x: -0.12095*width, y: 0.41797*height),control2: CGPoint(x: -0.19922*width, y: 0.41406*height))
        path.addCurve(to: CGPoint(x: -0.06641*width, y: 0.86719*height),control1: CGPoint(x: -0.19922*width, y: 0.82031*height),control2: CGPoint(x: -0.12681*width, y: 0.86719*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.93359*width, y: 0.86719*height))
        path.addCurve(to: CGPoint(x: 1.05273*width, y: 0.64844*height),control1: CGPoint(x: 0.994*width, y: 0.86719*height),control2: CGPoint(x: 1.05273*width, y: 0.79688*height))
        path.addCurve(to: CGPoint(x: 0.93945*width, y: 0.41797*height),control1: CGPoint(x: 1.05273*width, y: 0.5*height),control2: CGPoint(x: 0.99986*width, y: 0.41797*height))
        path.addCurve(to: CGPoint(x: 0.80078*width, y: 0.61719*height),control1: CGPoint(x: 0.87905*width, y: 0.41797*height),control2: CGPoint(x: 0.80078*width, y: 0.41406*height))
        path.addCurve(to: CGPoint(x: 0.93359*width, y: 0.86719*height),control1: CGPoint(x: 0.80078*width, y: 0.82031*height),control2: CGPoint(x: 0.87319*width, y: 0.86719*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.44922*width, y: 0.71875*height))
        path.addCurve(to: CGPoint(x: 0.48633*width, y: 0.62891*height),control1: CGPoint(x: 0.47266*width, y: 0.71875*height),control2: CGPoint(x: 0.48633*width, y: 0.67578*height))
        path.addCurve(to: CGPoint(x: 0.44336*width, y: 0.5625*height),control1: CGPoint(x: 0.48633*width, y: 0.58203*height),control2: CGPoint(x: 0.46385*width, y: 0.5625*height))
        path.addCurve(to: CGPoint(x: 0.40039*width, y: 0.65234*height),control1: CGPoint(x: 0.42286*width, y: 0.5625*height),control2: CGPoint(x: 0.40039*width, y: 0.61135*height))
        path.addCurve(to: CGPoint(x: 0.44922*width, y: 0.71875*height),control1: CGPoint(x: 0.40039*width, y: 0.69333*height),control2: CGPoint(x: 0.42578*width, y: 0.71875*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.19531*width, y: 0.92969*height))
        path.addCurve(to: CGPoint(x: 0.33789*width, y: 0.78125*height),control1: CGPoint(x: 0.24493*width, y: 0.92969*height),control2: CGPoint(x: 0.33789*width, y: 0.91406*height))
        path.addCurve(to: CGPoint(x: 0.19531*width, y: 0.57031*height),control1: CGPoint(x: 0.33789*width, y: 0.64844*height),control2: CGPoint(x: 0.25*width, y: 0.57031*height))
        path.addCurve(to: CGPoint(x: 0.10938*width, y: 0.75*height),control1: CGPoint(x: 0.14063*width, y: 0.57031*height),control2: CGPoint(x: 0.10547*width, y: 0.625*height))
        path.addCurve(to: CGPoint(x: 0.19531*width, y: 0.92969*height),control1: CGPoint(x: 0.11328*width, y: 0.875*height),control2: CGPoint(x: 0.14569*width, y: 0.92969*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.36719*width, y: 0.52344*height))
        path.addCurve(to: CGPoint(x: 0.49219*width, y: 0.36328*height),control1: CGPoint(x: 0.42578*width, y: 0.52344*height),control2: CGPoint(x: 0.49219*width, y: 0.43663*height))
        path.addCurve(to: CGPoint(x: 0.45703*width, y: 0.25781*height),control1: CGPoint(x: 0.49219*width, y: 0.32447*height),control2: CGPoint(x: 0.48524*width, y: 0.27695*height))
        path.addCurve(to: CGPoint(x: 0.36719*width, y: 0.25391*height),control1: CGPoint(x: 0.43193*width, y: 0.24079*height),control2: CGPoint(x: 0.38672*width, y: 0.25*height))
        path.addCurve(to: CGPoint(x: 0.2793*width, y: 0.39844*height),control1: CGPoint(x: 0.33095*width, y: 0.26115*height),control2: CGPoint(x: 0.2793*width, y: 0.32509*height))
        path.addCurve(to: CGPoint(x: 0.36719*width, y: 0.52344*height),control1: CGPoint(x: 0.2793*width, y: 0.47179*height),control2: CGPoint(x: 0.30859*width, y: 0.52344*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.72656*width, y: 0.95313*height))
        path.addCurve(to: CGPoint(x: 0.78125*width, y: 0.83594*height),control1: CGPoint(x: 0.75677*width, y: 0.95313*height),control2: CGPoint(x: 0.78125*width, y: 0.90625*height))
        path.addCurve(to: CGPoint(x: 0.72656*width, y: 0.71875*height),control1: CGPoint(x: 0.78125*width, y: 0.76563*height),control2: CGPoint(x: 0.75677*width, y: 0.71875*height))
        path.addCurve(to: CGPoint(x: 0.67188*width, y: 0.84375*height),control1: CGPoint(x: 0.69636*width, y: 0.71875*height),control2: CGPoint(x: 0.67188*width, y: 0.78334*height))
        path.addCurve(to: CGPoint(x: 0.6875*width, y: 0.93359*height),control1: CGPoint(x: 0.67188*width, y: 0.87658*height),control2: CGPoint(x: 0.67605*width, y: 0.91355*height))
        path.addCurve(to: CGPoint(x: 0.72656*width, y: 0.95313*height),control1: CGPoint(x: 0.69712*width, y: 0.95044*height),control2: CGPoint(x: 0.71277*width, y: 0.95313*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.58594*width, y: 0.76563*height))
        path.addCurve(to: CGPoint(x: 0.66211*width, y: 0.64844*height),control1: CGPoint(x: 0.62373*width, y: 0.76563*height),control2: CGPoint(x: 0.64976*width, y: 0.71018*height))
        path.addCurve(to: CGPoint(x: 0.66211*width, y: 0.56641*height),control1: CGPoint(x: 0.66602*width, y: 0.62891*height),control2: CGPoint(x: 0.6647*width, y: 0.58565*height))
        path.addCurve(to: CGPoint(x: 0.58594*width, y: 0.45313*height),control1: CGPoint(x: 0.64844*width, y: 0.46484*height),control2: CGPoint(x: 0.62908*width, y: 0.45313*height))
        path.addCurve(to: CGPoint(x: 0.50391*width, y: 0.60938*height),control1: CGPoint(x: 0.54279*width, y: 0.45313*height),control2: CGPoint(x: 0.50391*width, y: 0.52308*height))
        path.addCurve(to: CGPoint(x: 0.52344*width, y: 0.71875*height),control1: CGPoint(x: 0.50391*width, y: 0.6502*height),control2: CGPoint(x: 0.51044*width, y: 0.69092*height))
        path.addCurve(to: CGPoint(x: 0.58594*width, y: 0.76563*height),control1: CGPoint(x: 0.53792*width, y: 0.74975*height),control2: CGPoint(x: 0.56021*width, y: 0.76563*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.70898*width, y: 0.41016*height))
        path.addCurve(to: CGPoint(x: 0.79297*width, y: 0.23438*height),control1: CGPoint(x: 0.75213*width, y: 0.41016*height),control2: CGPoint(x: 0.79297*width, y: 0.32067*height))
        path.addCurve(to: CGPoint(x: 0.71094*width, y: 0.08984*height),control1: CGPoint(x: 0.79297*width, y: 0.14808*height),control2: CGPoint(x: 0.76758*width, y: 0.08984*height))
        path.addCurve(to: CGPoint(x: 0.62891*width, y: 0.25391*height),control1: CGPoint(x: 0.66779*width, y: 0.08984*height),control2: CGPoint(x: 0.62891*width, y: 0.16761*height))
        path.addCurve(to: CGPoint(x: 0.70898*width, y: 0.41016*height),control1: CGPoint(x: 0.62891*width, y: 0.38672*height),control2: CGPoint(x: 0.67188*width, y: 0.41016*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4375*width, y: 0.11328*height))
        path.addCurve(to: CGPoint(x: 0.56055*width, y: 0.10156*height),control1: CGPoint(x: 0.45898*width, y: 0.12109*height),control2: CGPoint(x: 0.52844*width, y: 0.12856*height))
        path.addCurve(to: CGPoint(x: 0.60352*width, y: 0.02734*height),control1: CGPoint(x: 0.58086*width, y: 0.08449*height),control2: CGPoint(x: 0.5981*width, y: 0.05986*height))
        path.addCurve(to: CGPoint(x: 0.60156*width, y: -0.05469*height),control1: CGPoint(x: 0.60742*width, y: 0.00391*height),control2: CGPoint(x: 0.60547*width, y: -0.03906*height))
        path.addCurve(to: CGPoint(x: 0.4375*width, y: -0.21094*height),control1: CGPoint(x: 0.58111*width, y: -0.13651*height),control2: CGPoint(x: 0.50781*width, y: -0.20703*height))
        path.addCurve(to: CGPoint(x: 0.35938*width, y: -0.05469*height),control1: CGPoint(x: 0.39435*width, y: -0.21094*height),control2: CGPoint(x: 0.35938*width, y: -0.14098*height))
        path.addCurve(to: CGPoint(x: 0.4375*width, y: 0.11328*height),control1: CGPoint(x: 0.35938*width, y: 0.03161*height),control2: CGPoint(x: 0.3959*width, y: 0.09815*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.4375*width, y: 1.11328*height))
        path.addCurve(to: CGPoint(x: 0.56055*width, y: 1.10156*height),control1: CGPoint(x: 0.45898*width, y: 1.12109*height),control2: CGPoint(x: 0.52844*width, y: 1.12856*height))
        path.addCurve(to: CGPoint(x: 0.60352*width, y: 1.02734*height),control1: CGPoint(x: 0.58086*width, y: 1.08449*height),control2: CGPoint(x: 0.5981*width, y: 1.05986*height))
        path.addCurve(to: CGPoint(x: 0.60156*width, y: 0.94531*height),control1: CGPoint(x: 0.60742*width, y: 1.00391*height),control2: CGPoint(x: 0.60547*width, y: 0.96094*height))
        path.addCurve(to: CGPoint(x: 0.4375*width, y: 0.78906*height),control1: CGPoint(x: 0.58111*width, y: 0.86349*height),control2: CGPoint(x: 0.50781*width, y: 0.79297*height))
        path.addCurve(to: CGPoint(x: 0.35938*width, y: 0.94531*height),control1: CGPoint(x: 0.39435*width, y: 0.78906*height),control2: CGPoint(x: 0.35938*width, y: 0.85902*height))
        path.addCurve(to: CGPoint(x: 0.4375*width, y: 1.11328*height),control1: CGPoint(x: 0.35938*width, y: 1.03161*height),control2: CGPoint(x: 0.3959*width, y: 1.09815*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.25195*width, y: 0.23047*height))
        path.addCurve(to: CGPoint(x: 0.3418*width, y: 0.07422*height),control1: CGPoint(x: 0.29726*width, y: 0.23047*height),control2: CGPoint(x: 0.3418*width, y: 0.16483*height))
        path.addCurve(to: CGPoint(x: 0.26758*width, y: -0.07813*height),control1: CGPoint(x: 0.3418*width, y: -0.01639*height),control2: CGPoint(x: 0.31288*width, y: -0.07813*height))
        path.addCurve(to: CGPoint(x: 0.17969*width, y: 0.07422*height),control1: CGPoint(x: 0.22227*width, y: -0.07813*height),control2: CGPoint(x: 0.17969*width, y: -0.01953*height))
        path.addCurve(to: CGPoint(x: 0.25195*width, y: 0.23047*height),control1: CGPoint(x: 0.17969*width, y: 0.16797*height),control2: CGPoint(x: 0.20665*width, y: 0.23047*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.25195*width, y: 1.23047*height))
        path.addCurve(to: CGPoint(x: 0.3418*width, y: 1.07422*height),control1: CGPoint(x: 0.29726*width, y: 1.23047*height),control2: CGPoint(x: 0.3418*width, y: 1.16483*height))
        path.addCurve(to: CGPoint(x: 0.26758*width, y: 0.92188*height),control1: CGPoint(x: 0.3418*width, y: 0.98361*height),control2: CGPoint(x: 0.31288*width, y: 0.92188*height))
        path.addCurve(to: CGPoint(x: 0.17969*width, y: 1.07422*height),control1: CGPoint(x: 0.22227*width, y: 0.92188*height),control2: CGPoint(x: 0.17969*width, y: 0.98047*height))
        path.addCurve(to: CGPoint(x: 0.25195*width, y: 1.23047*height),control1: CGPoint(x: 0.17969*width, y: 1.16797*height),control2: CGPoint(x: 0.20665*width, y: 1.23047*height))
        path.closeSubpath()

        return path
    }
}

struct MyCustomShape_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BubbleView(size: geo.size)
        }
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

