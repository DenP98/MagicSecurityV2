//
//  SecurityMonitor.swift
//  MagicSecurity
//
//  Created by User on 29.04.25.
//

import UIKit
import CoreMotion
import AVFoundation
import Foundation

actor SecurityMonitor {
    private let motionManager = CMMotionManager()
    private var audioSession = AVAudioSession.sharedInstance()
    private var isObservingPower = false
    private var isObservingHeadphones = false
    private var powerObserver: NSObjectProtocol?
    private var headphonesObserver: NSObjectProtocol?
    
    private let audioPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "alarm", withExtension: "mp3")!)
    private var lastRoll: Double?
    private var lastPitch: Double?
    private var lastYaw: Double?
    private var isAlarming = false
    private var timer: Timer?
    
    init() {
        audioPlayer?.prepareToPlay()
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.volume = 1.0
    }
    
    func startMovementMonitoring() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion else { return }
            
            let roll = motion.attitude.roll
            let pitch = motion.attitude.pitch
            let yaw = motion.attitude.yaw
            let accelerationX = motion.userAcceleration.x
            let accelerationY = motion.userAcceleration.y
            let accelerationZ = motion.userAcceleration.z
            
            Task { [weak self] in
                await self?.handleMotionData(
                    roll: roll,
                    pitch: pitch,
                    yaw: yaw,
                    accelerationX: accelerationX,
                    accelerationY: accelerationY,
                    accelerationZ: accelerationZ
                )
            }
        }
    }
    
    func stopMovementMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        lastRoll = nil
        lastPitch = nil
        lastYaw = nil
        if isAlarming {
            stopAlarm()
        }
    }
    
    private func handleMotionData(
        roll: Double,
        pitch: Double,
        yaw: Double,
        accelerationX: Double,
        accelerationY: Double,
        accelerationZ: Double
    ) {
        guard !isAlarming else { return }
        
        if let lastRoll = lastRoll,
           let lastPitch = lastPitch,
           let lastYaw = lastYaw {
            let rotationThreshold = 0.5
            
            let rotationDifference = abs(roll - lastRoll) +
                                   abs(pitch - lastPitch) +
                                   abs(yaw - lastYaw)
            
            let magnitude = sqrt(
                pow(accelerationX, 2) +
                pow(accelerationY, 2) +
                pow(accelerationZ, 2)
            )
            
            if rotationDifference > rotationThreshold || magnitude > 1.5 {
                handleAlarm(.movement)
            }
        }
        
        self.lastRoll = roll
        self.lastPitch = pitch
        self.lastYaw = yaw
    }
    
    func startPowerMonitoring() async {
        guard !isObservingPower else { return }
        isObservingPower = true
        
        await MainActor.run {
            UIDevice.current.isBatteryMonitoringEnabled = true
        }
        
        powerObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard UIDevice.current.batteryState == .unplugged else {
                    return
                }
                await self?.handleAlarm(.power)
            }
        }
    }
    
    func stopPowerMonitoring() async {
        isObservingPower = false
        
        await MainActor.run {
            UIDevice.current.isBatteryMonitoringEnabled = false
        }
        
        if let powerObserver {
            NotificationCenter.default.removeObserver(powerObserver)
            self.powerObserver = nil
        }
        if isAlarming {
            stopAlarm()
        }
    }
    
    func startHeadphonesMonitoring() {
        guard !isObservingHeadphones else { return }
        isObservingHeadphones = true
        
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            headphonesObserver = NotificationCenter.default.addObserver(
                forName: AVAudioSession.routeChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let userInfo = notification.userInfo,
                      let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                      let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue),
                      reason == .oldDeviceUnavailable
                else { return }
                
                Task { [weak self] in
                    await self?.handleAlarm(.headphones)
                }
            }
        } catch {
            print("Failed to activate audio session: \(error)")
        }
    }
    
    func stopHeadphonesMonitoring() {
        isObservingHeadphones = false
        
        if let headphonesObserver {
            NotificationCenter.default.removeObserver(headphonesObserver)
            self.headphonesObserver = nil
        }
        if isAlarming {
            stopAlarm()
        }
    }
    
    private func handleAlarm(_ type: AlarmType) {
        guard !isAlarming else { return }
        print("Alarm triggered: \(type)")
        
        do {
            isAlarming = true
            try audioSession.setCategory(.playback, mode: .default)
//            try audioSession.setActive(true)
//            audioPlayer?.play()
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                Task { [weak self] in
                    await self?.stopAlarm()
                }
            }
        } catch {
            print("Failed to play alarm: \(error)")
            isAlarming = false
        }
    }
    
    private func stopAlarm() {
        isAlarming = false
        audioPlayer?.stop()
        timer?.invalidate()
        timer = nil
    }
    
    enum AlarmType {
        case movement
        case power
        case headphones
    }
}
