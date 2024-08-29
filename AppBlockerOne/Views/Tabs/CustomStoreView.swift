//
//  StoreView.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/29/24.
//

import SwiftUI
import StoreKit

struct CustomStoreView: View {
    @Environment(StoreModel.self) private var storeModel
    @State private var alertTitle: String? = nil
    @State private var alertMsg: String? = nil
    @State private var isShowRefund: Bool = false
    
    private var isShowAlert: Binding<Bool> {
        Binding(get: {
            return alertMsg != nil && alertTitle != nil
        }, set: {
            if !$0 {
                alertMsg = nil
                alertTitle = nil
            }
        })
    }
    
    private var isShowRefundButton: Bool {
        false
        // TODO: Fix this when possible
//        storeModel.premiumShieldTransactionId != nil
    }
    

    var body: some View {
        NavigationStack {
            Color.bg
                .ignoresSafeArea()
                .overlay {
                    ScrollView{
                        VStack{
                            ProductView(id: StoreModel.PRODUCT_ID_PREMIUM_SHIELD)
                            { _ in
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.gray)
                                    .overlay {
                                        Image("premiumShieldIcon")
                                            .resizable()
                                            .scaledToFit()
                                            .padding()
                                    }
                            } placeholderIcon: {
                                ProgressView()
                            }
                            .productViewStyle(.large)
                            .padding(.top)
                            .onInAppPurchaseStart {_ in
                                debugPrint("TODO: In app purchase start")
                            }
                            .onInAppPurchaseCompletion {_,result in
                                do {
                                    try await storeModel.handlePurchaseCompletion(result: result)
                                }
                                catch {
                                    alertTitle = "Purchase failed"
                                    alertMsg = error.localizedDescription
                                    debugPrint(error.localizedDescription)
                                }
                            }
                            Text("Support our indie studio by buying the premium duck shield! This icon will show up when you try to open a blocked app.")
                                .padding(.vertical)
                                .font(.subheadline)
                            if isShowRefundButton {
                                Button(action: {
                                    isShowRefund = true
                                }) {
                                    Text("Request refund")
                                }
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("Duck Store")
                .navigationBarTitleDisplayMode(.large)
                .refundRequestSheet(for: storeModel.premiumShieldTransactionId ?? 0, isPresented: $isShowRefund, onDismiss: onRefundDismiss)
                .alert(
                    Text(alertTitle ?? ""),
                    isPresented: isShowAlert
                ) {
                    Button("OK") {
                        // Handle the acknowledgement.
                    }
                } message: {
                    Text(alertMsg ?? "")
                }
        }
    }
    
    private func onRefundDismiss(result: Result<StoreKit.Transaction.RefundRequestStatus, StoreKit.Transaction.RefundRequestError>){
        switch result {
        case .success(let refundStatus):
            switch refundStatus {
            case .success:
                print("Handling it")
                storeModel.handlePremiumBlockRefund()
            case .userCancelled:
                break
            @unknown default:
                break
            }
        case .failure(let errorVal):
            alertTitle = "Refund failed"
            debugPrint(errorVal.errorDescription ?? "")
            debugPrint(errorVal.failureReason ?? "")
            alertMsg = errorVal.localizedDescription
        }
    }
}

struct CustomStoreView_Previews: PreviewProvider {
    struct Container: View {
        @State private var storeModel = StoreModel()
        
        var body: some View {
            TabView {
                CustomStoreView()
            }
            .environment(storeModel)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
