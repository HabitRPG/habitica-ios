//
//  SoundManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import AVFoundation
import Habitica_Models

enum SoundEffect: String {
    case achievementUnlocked = "Achievement_Unlocked"
    case chat = "Chat"
    case dailyCompleted = "Daily"
    case death = "Death"
    case itemDropped = "Item_Drop"
    case levelUp = "Level_Up"
    case habitNegative = "Minus_Habit"
    case habitPositive = "Plus_Habit"
    case rewardBought = "Reward"
    case todoCompleted = "Todo"
    
    static var allEffects: [SoundEffect] {
        return [
            SoundEffect.achievementUnlocked,
            SoundEffect.chat,
            SoundEffect.dailyCompleted,
            SoundEffect.death,
            SoundEffect.itemDropped,
            SoundEffect.levelUp,
            SoundEffect.habitPositive,
            SoundEffect.habitNegative,
            SoundEffect.rewardBought,
            SoundEffect.todoCompleted
        ]
    }
}

enum SoundTheme: String, EquatableStringEnumProtocol {
    case none = "off"
    case airu = "airuTheme"
    case arashi = "arashiTheme"
    case beatScribeNes = "beatscribeNesTheme"
    case danielTheBard = "danielTheBard"
    case dewin = "dewinTheme"
    case farvoid = "farvoidTheme"
    case gokul = "gokulTheme"
    case lunasol = "lunasolTheme"
    case luneFox = "luneFoxTheme"
    case mafl = "maflTheme"
    case pizilden = "pizildenTheme"
    case rosstavo = "rosstavoTheme"
    case spacePengiun = "spacePengiunTheme"
    case triumph = "triumphTheme"
    case watts = "wattsTheme"
    
    static var allThemes: [SoundTheme] {
        return [
            SoundTheme.none,
            SoundTheme.airu,
            SoundTheme.arashi,
            SoundTheme.beatScribeNes,
            SoundTheme.danielTheBard,
            SoundTheme.dewin,
            SoundTheme.farvoid,
            SoundTheme.gokul,
            SoundTheme.lunasol,
            SoundTheme.luneFox,
            SoundTheme.mafl,
            SoundTheme.pizilden,
            SoundTheme.rosstavo,
            SoundTheme.spacePengiun,
            SoundTheme.triumph,
            SoundTheme.watts
        ]
    }
    
    var niceName: String {
        switch self {
        case .none:
            return "Off"
        case .airu:
            return "Airu's Theme"
        case .arashi:
            return "Arashi's Theme"
        case .beatScribeNes:
            return "Beatscribe's NES Theme"
        case .danielTheBard:
            return "Daniel The Bard"
        case .dewin:
            return "Dewin's Theme"
        case .farvoid:
            return "Farvoid Theme"
        case .gokul:
            return "Gokul's Theme"
        case .lunasol:
            return "Lunasol Theme"
        case .luneFox:
            return "LuneFox's Theme"
        case .mafl:
            return "MAFL Theme"
        case .pizilden:
            return "Pizilden's Theme"
        case .rosstavo:
            return "Rosstavo's Theme"
        case .spacePengiun:
            return "SpacePenguin's Theme"
        case .triumph:
            return "Triumph's Theme"
        case .watts:
            return "Watts' Theme"
        }
    }
}

class SoundManager {
    
    public static let shared = SoundManager()
    
    var currentTheme = SoundTheme.none {
        didSet {
            if currentTheme != oldValue {
                loadAllFiles()
            }
        }
    }
    private var player: AVAudioPlayer?
    
    private var soundsDirectory: URL? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        if paths.isEmpty == false {
            let folderPath = String(paths[0])
            var folder = URL(fileURLWithPath: folderPath)
            folder = folder.appendingPathComponent("sounds", isDirectory: true)
            return folder
        }
        
        return nil
    }
    
    private init() {
        let defaults = UserDefaults.standard
        currentTheme = SoundTheme(rawValue: defaults.string(forKey: "soundTheme") ?? "") ?? SoundTheme.none
    }
    
    func play(effect: SoundEffect) {
        if currentTheme == SoundTheme.none {
            return
        }
        guard let url = soundsDirectory?.appendingPathComponent("\(currentTheme.rawValue)/\(effect.rawValue).mp3") else {
            return
        }
        
        if !FileManager.default.fileExists(atPath: url.path) {
            return
        }
        
        do {
            if #available(iOS 10.0, *) {
                try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            } else {
                // Fallback on earlier versions
            }
            try? AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try? AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else {
                return
            }
            
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func loadAllFiles() {
        if currentTheme == SoundTheme.none {
            return
        }
        if let soundThemeDirectory = self.soundsDirectory?.appendingPathComponent("\(currentTheme.rawValue)") {
            if !FileManager.default.fileExists(atPath: soundThemeDirectory.path, isDirectory: nil) {
                try? FileManager.default.createDirectory(at: soundThemeDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            SoundEffect.allEffects.forEach {[weak self] (effect) in
                self?.load(soundEffect: effect)
            }
        }
    }
    
    private func load(soundEffect: SoundEffect) {
        let effectPath = "\(currentTheme.rawValue)/\(soundEffect.rawValue).mp3"
        guard let url = URL(string: "https://s3.amazonaws.com/habitica-assets/mobileApp/sounds/\(effectPath)") else {
            return
        }
        guard let soundsDirectory = self.soundsDirectory else {
            return
        }
        let localUrl = soundsDirectory.appendingPathComponent(effectPath)
        if FileManager.default.fileExists(atPath: localUrl.path) {
            return
        }
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, _, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                do {
                    try FileManager.default.moveItem(at: tempLocalUrl, to: localUrl)
                } catch let writeError {
                    print("error writing file \(localUrl) : \(writeError)")
                }
            } else {
                print("Failure: %@", error?.localizedDescription ?? "")
            }
        }
        task.resume()
    }
}
