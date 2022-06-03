//
//  JobDetailPageContainer.swift
//  imink
//
//  Created by Jone Wang on 2022/6/3.
//

import SwiftUI

struct JobDetailPageContainer: View {
    @EnvironmentObject var synchronizeJobViewModel: SynchronizeJobViewModel

    @StateObject var viewModel: JobDetailContainerViewModel

    var showPage: (Int64) -> Void
    var initPageId: Int64
    @Binding var isPresented: Bool

    @State private var showFloatButton: Bool = false
    @State private var isTouchSelection: Bool = true

    var selectedRow: JobListRowModel

    private var navigationTitle: String {
        "ID: \(viewModel.currentJobId)"
    }

    private var onlyOne: Bool {
        synchronizeJobViewModel.synchronizing
    }

    var body: some View {
        ScrollViewReader { proxy in
            Group {
                // Do not allow scrolling when synchronization is in progress.
                onlyOne ? AnyView(singleJob) : AnyView(makeMultipleJob(proxy: proxy))
            }
            .ignoresSafeArea()
            .overlay(
                LatestDataFloatButton(isPresent: $showFloatButton, action: {
                    if !onlyOne {
                        withAnimation {
                            proxy.scrollTo(viewModel.pages.first?.id)
                        }
                    }
                }),
                alignment: .bottom
            )
            .onChange(of: synchronizeJobViewModel.newMessage) { newValue in
                if newValue {
                    showFloatButton = true
                }
            }
        }
        .navigationBarTitle(navigationTitle, displayMode: .inline)
        .onDisappear {
            isPresented = false
        }
        .onChange(of: selectedRow) { row in
            viewModel.update(dbJob: row.job!, initPageId: initPageId)
        }
    }

    var singleJob: some View {
        Group {
            if let dbJobIndex = viewModel.dbJobIndex(with: initPageId) {
                let page = viewModel.pages[dbJobIndex]
                JobDetailPage(viewModel: page)
                    .id(page.dbJob.id)
            } else {
                EmptyView()
            }
        }
        .background(AppColor.listBackgroundColor)
    }

    func makeMultipleJob(proxy: ScrollViewProxy) -> some View {
        GeometryReader { geo in
            let pageWidth = geo.size.width
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(viewModel.pages) { page in
                        // Wrapping JobDetailPage with View is used to prevent
                        // the problem of the previous page not being released.
                        // It is caused by the Lazy Stack and the id() function working together.
                        // ZStack is used here, but it can be any View.
                        ZStack {
                            JobDetailPage(viewModel: page)
                        }
                        .frame(width: pageWidth, height: geo.size.height)
                        .id(page.id)
                    }
                }
            }
            .onChange(of: initPageId) { pageId in
                isTouchSelection = true
                proxy.scrollTo(pageId)
            }
            .onAppear {
                withAnimation {
                    proxy.scrollTo(initPageId)
                }
            }
            .background(AppColor.listBackgroundColor)
            .scrollViewPaging()
            .scrollViewScroll { offset in
                showFloatButton = false
                
                let pageIndex = Int(round(offset.x / pageWidth))
                
                if !viewModel.pages.indices.contains(pageIndex) { return }
                guard let pageId = viewModel.pages[pageIndex].id else { return }
                if viewModel.pages[pageIndex].id == viewModel.currentPageId { return }

                viewModel.currentPageId = pageId
                if !isTouchSelection {
                    showPage(pageId)
                } else {
                    isTouchSelection = false
                }
            }
        }
    }
}

//struct JobDetailPageContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        JobDetailPageContainer()
//    }
//}
