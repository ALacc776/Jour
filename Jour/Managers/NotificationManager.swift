//
//  NotificationManager.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import Foundation
import UserNotifications

/// Manages notification reminders for journaling
/// Sends daily reminders to help users maintain their streak
class NotificationManager: ObservableObject {
    // MARK: - Published Properties
    
    /// Whether notifications are enabled
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
            if notificationsEnabled {
                requestPermissionAndSchedule()
            } else {
                cancelAllNotifications()
            }
        }
    }
    
    /// Time for daily reminder (hour, 0-23)
    @Published var reminderHour: Int {
        didSet {
            UserDefaults.standard.set(reminderHour, forKey: "reminder_hour")
            if notificationsEnabled {
                scheduleNotifications()
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        self.reminderHour = UserDefaults.standard.object(forKey: "reminder_hour") as? Int ?? 20 // 8 PM default
    }
    
    // MARK: - Public Methods
    
    /// Requests notification permission and schedules if granted
    func requestPermissionAndSchedule() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                if granted {
                    self.scheduleNotifications()
                } else {
                    self.notificationsEnabled = false
                }
            }
        }
    }
    
    /// Schedules daily reminder notifications
    func scheduleNotifications() {
        // Cancel existing notifications
        cancelAllNotifications()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to log your day"
        content.body = "Take a moment to reflect on what you did today"
        content.sound = .default
        content.badge = 1
        
        // Create trigger for daily at specified hour
        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    /// Cancels all scheduled notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    /// Checks current notification authorization status
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
}

