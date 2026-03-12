//
//  ContentView.swift
//  BipTheGuy
//
//  Created by Louise Verbeke on 12/03/2026.
//

import SwiftUI
import AVFAudio
import PhotosUI

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer!
    @State private var isFullSize = true
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var bipImage = Image("clown")
    @AppStorage("savedImageData") private var savedImageData: Data?
    
    var body: some View {
        VStack {
            Spacer()
            
            bipImage
                .resizable()
                .scaledToFit()
                .scaleEffect(isFullSize ? 1.0 : 0.9)
                .onTapGesture {
                    playSound(soundName: "punchSound")
                    isFullSize = false // will immediately shrink using .scaleEffect to 90% of size
                    withAnimation (.spring(response: 0.3, dampingFraction: 0.3)) {
                        isFullSize = true // will go from 90% to 100% size but using the .spring animation
                    }
                }
            
            Spacer()
            
            PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                Label("Photo library", systemImage: "photo.fill.on.rectangle.fill")
                    .font(.title2)
                
            }
            .buttonStyle(.glassProminent)
            .tint(.green.opacity(0.7))
            .controlSize(.large)
            .onChange(of: selectedPhoto) {
                Task {
                    guard let selectedPhoto = selectedPhoto,
                          let imageData = try? await
                            selectedPhoto
                        .loadTransferable(type:
                                            Data.self) else {
                        print("😡ERROR: Could not get Image from loadTransferrable")
                        return
                    }
                    savedImageData = imageData
                    
                    if let uiImage = UIImage(data: imageData) {
                        bipImage = Image(uiImage: uiImage)
                    }
                    
                }
            }
        
        }
        .padding()
    }
    
    func playSound(soundName: String) {
        if audioPlayer != nil && audioPlayer.isPlaying {
        audioPlayer.stop()
    }
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("😡 Could not read file named \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("😡 ERROR: \(error.localizedDescription) creating audioPlayer")
        }
    }
}

#Preview {
    ContentView()
}

