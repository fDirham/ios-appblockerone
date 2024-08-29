//
//  StoreModel.swift
//  DuckBlock
//
//  Created by Fajar Dirham on 8/29/24.
//

import Foundation
import StoreKit

@Observable class StoreModel {
    private(set) var products: [Product] = []
    private(set) var activeTransactions: Set<StoreKit.Transaction> = []
    private var updates: Task<Void, Never>?
    var premiumShieldTransactionId: UInt64? = nil
    
    static let PRODUCT_ID_PREMIUM_SHIELD = "duckblock.duckshield"
    
    init() {
        Task {
            await fetchActiveTransactions()
        }
        
        updates = Task {
            for await update in StoreKit.Transaction.updates {
                await handleUpdates(updatedTransaction: update)
            }
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    private func handleUpdates(updatedTransaction verificationResult: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            return
        }
        
        if transaction.revocationDate != nil {
            if transaction.appBundleID == Self.PRODUCT_ID_PREMIUM_SHIELD {
                await fetchActiveTransactions()
                await transaction.finish()
            }
        } else if let expirationDate = transaction.expirationDate,
                  expirationDate < Date() {
            // Do nothing, this subscription is expired.
            return
        } else if transaction.isUpgraded {
            // Do nothing, there is an active transaction
            // for a higher level of service.
            return
        } else {
            // Provide access to the product identified by
            // transaction.productID.
            await _onItemSuccessPurchase(transaction: transaction)
        }
    }
    
    func fetchActiveTransactions() async {
        var activeTransactions: Set<StoreKit.Transaction> = []
        
        for await entitlement in StoreKit.Transaction.currentEntitlements {
            if let transaction = try? entitlement.payloadValue {
                activeTransactions.insert(transaction)
            }
        }
        
        self.activeTransactions = activeTransactions
        processTransactions()
    }
    
    func handlePurchaseCompletion(result: Result<Product.PurchaseResult, any Error>) async throws {
        switch result {
        case .success(let purchaseResult):
            switch purchaseResult {
            case .success(let verificationResult):
                if let transaction = try? verificationResult.payloadValue {
                    await _onItemSuccessPurchase(transaction: transaction)
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        case .failure(let errorVal):
            throw errorVal
        }
    }
    
    private func _onItemSuccessPurchase(transaction: StoreKit.Transaction) async{
        activeTransactions = [transaction]
        await transaction.finish()
        processTransactions()
    }
    
    private func processTransactions(){
        do {
            let ud = GroupUserDefaults()
            var currMainSettings: MainSettingsDefault = try ud.getObj(forKey: DEFAULT_KEY_MAIN_SETTINGS) ?? MainSettingsDefault()
            
            if let premiumShieldTransaction = activeTransactions.first(where: {e in e.productID == Self.PRODUCT_ID_PREMIUM_SHIELD}) {
                currMainSettings.usePremiumShield = true
                premiumShieldTransactionId = premiumShieldTransaction.id
            }
            else {
                currMainSettings.usePremiumShield = false
                premiumShieldTransactionId = nil
            }
            try ud.setObj(currMainSettings, forKey: DEFAULT_KEY_MAIN_SETTINGS)
        }
        catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func handlePremiumBlockRefund(){
        activeTransactions = []
        processTransactions()
    }
}
