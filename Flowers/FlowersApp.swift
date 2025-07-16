//
//  FlowersApp.swift
//  Flowers
//
//  Created by James Frewin on 14/07/2025.
//

import SwiftUI
import UserNotifications

@main
struct FlowersApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var flowerStore = FlowerStore()
    @State private var showingImportConfirmation = false
    @State private var importedFlower: AIFlower?
    @State private var importedSenderInfo: FlowerOwner?
    let contextualGenerator = ContextualFlowerGenerator.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(flowerStore)
                .onAppear {
                    // Initialize contextual generator
                    _ = contextualGenerator
                    
                    // Request notification permissions on first launch
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        if granted {
                            print("Notification permission granted")
                        }
                    }
                }
                .fullScreenCover(isPresented: $flowerStore.hasUnrevealedFlower) {
                    if let pendingFlower = flowerStore.pendingFlower {
                        FlowerRevealView(flower: pendingFlower)
                            .environmentObject(flowerStore)
                    }
                }
                .onOpenURL { url in
                    handleIncomingFile(url)
                }
                .sheet(isPresented: $showingImportConfirmation) {
                    if let flower = importedFlower, let sender = importedSenderInfo {
                        ReceivedFlowerSheet(
                            flower: flower,
                            sender: sender,
                            onAccept: {
                                flowerStore.addReceivedFlower(flower)
                                showingImportConfirmation = false
                                importedFlower = nil
                                importedSenderInfo = nil
                            },
                            onReject: {
                                showingImportConfirmation = false
                                importedFlower = nil
                                importedSenderInfo = nil
                            }
                        )
                    }
                }
        }
    }
    
    private func handleIncomingFile(_ url: URL) {
        guard url.pathExtension == "flower" else { return }
        
        do {
            let (flower, senderInfo) = try FlowerTransferService.shared.importFlower(from: url)
            importedFlower = flower
            importedSenderInfo = senderInfo
            showingImportConfirmation = true
        } catch {
            print("Failed to import flower: \(error)")
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Clear badge on app launch
        UNUserNotificationCenter.current().setBadgeCount(0)
        
        return true
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Clear badge when notification is tapped
        UNUserNotificationCenter.current().setBadgeCount(0)
        completionHandler()
    }
}
