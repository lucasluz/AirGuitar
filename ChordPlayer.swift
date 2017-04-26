//
//  ChordPlayer.swift
//  AirGuitar
//
//  Created by Lucas Luz on 03/03/17.
//  Copyright © 2017 Lucas Luz. All rights reserved.
//

import Foundation
import AVFoundation

class ChordPlayer : NSObject {
    var audioPlayer : AVAudioPlayer!
    var audioPlayer2 : AVAudioPlayer!
    var audioPlayer3 : AVAudioPlayer!
    var audioPlayer4 : AVAudioPlayer!
    
    let C = Bundle.main.url(forResource: "C", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let Cm = Bundle.main.url(forResource: "Cm", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let D = Bundle.main.url(forResource: "D", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let Dm = Bundle.main.url(forResource: "Dm", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let E = Bundle.main.url(forResource: "E", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let Em = Bundle.main.url(forResource: "Em", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let F = Bundle.main.url(forResource: "F", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let Fm = Bundle.main.url(forResource: "Fm", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let G = Bundle.main.url(forResource: "G", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let Gm = Bundle.main.url(forResource: "Gm", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let A = Bundle.main.url(forResource: "A", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let Am = Bundle.main.url(forResource: "Am", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let B = Bundle.main.url(forResource: "B", withExtension: "aiff", subdirectory: "sounds/acoustic")
    let Bm = Bundle.main.url(forResource: "Bm", withExtension: "aiff", subdirectory: "sounds/acoustic")
    
    let Ce = Bundle.main.url(forResource: "C", withExtension: "aiff", subdirectory: "sounds/eletric")
    let De = Bundle.main.url(forResource: "D", withExtension: "aiff", subdirectory: "sounds/eletric")
    let Ee = Bundle.main.url(forResource: "E", withExtension: "aiff", subdirectory: "sounds/eletric")
    let Fe = Bundle.main.url(forResource: "F", withExtension: "aiff", subdirectory: "sounds/eletric")
    let Ge = Bundle.main.url(forResource: "G", withExtension: "aiff", subdirectory: "sounds/eletric")
    let Ae = Bundle.main.url(forResource: "A", withExtension: "aiff", subdirectory: "sounds/eletric")
    let Be = Bundle.main.url(forResource: "B", withExtension: "aiff", subdirectory: "sounds/eletric")
    
    override init() {
        
    }
    
    func playChord(_ chord:String, eletric:Bool) {
        do {
            var tmpChord : URL!
            
            if(!eletric) {
                switch chord {
                case "C" : tmpChord = C
                case "Cm" : tmpChord = Cm
                case "D" : tmpChord = D
                case "Dm" : tmpChord = Dm
                case "E" : tmpChord = E
                case "Em" : tmpChord = Em
                case "F" : tmpChord = F
                case "Fm" : tmpChord = Fm
                case "G" : tmpChord = G
                case "Gm" : tmpChord = Gm
                case "A" : tmpChord = A
                case "Am" : tmpChord = Am
                case "B" : tmpChord = B
                case "Bm" : tmpChord = Bm
                default : tmpChord = nil
                }
            } else {
                switch chord {
                case "C" : tmpChord = Ce
                case "D" : tmpChord = De
                case "E" : tmpChord = Ee
                case "F" : tmpChord = Fe
                case "G" : tmpChord = Ge
                case "A" : tmpChord = Ae
                case "B" : tmpChord = Be
                default : tmpChord = nil
                }
            }
            
            if(audioPlayer == nil || !audioPlayer.isPlaying) {
                try audioPlayer = AVAudioPlayer(contentsOf: tmpChord!)
                audioPlayer.play()
                
            } else if(audioPlayer2 == nil || !audioPlayer2.isPlaying){
                try audioPlayer2 = AVAudioPlayer(contentsOf: tmpChord!)
                audioPlayer2.play()

            } else if(audioPlayer3 == nil || !audioPlayer3.isPlaying){
                try audioPlayer3 = AVAudioPlayer(contentsOf: tmpChord!)
                audioPlayer3.play()

            } else {
                try audioPlayer4 = AVAudioPlayer(contentsOf: tmpChord!)
                audioPlayer4.play()

            }
            
        } catch {
            print("Error")
        }
    }
    
    func playPCM() {
        do {
            let chordC =  Bundle.main.url(forResource: "c", withExtension: "caf", subdirectory: "sounds")
            
            try audioPlayer = AVAudioPlayer(contentsOf: chordC!)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            print("play")
            
        } catch {
            print("Error")
        }
    }
    
}
