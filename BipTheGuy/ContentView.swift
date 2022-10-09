//
//  ContentView.swift
//  BipTheGuy
//
//  Created by Felix Leitl on 09.10.22.
//

import SwiftUI
import AVFAudio
import PhotosUI

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer!
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var animateImage = true
    @State private var bipimage = Image("clown")
    
    var body: some View {
        VStack {
            Spacer()
            
            bipimage
                .resizable()
                .scaledToFit()
                .scaleEffect(animateImage ? 1.0 : 0.9)
                .onTapGesture {
                    playSound(soundname: "punchSound")
                    animateImage = false
                    withAnimation (.spring(response: 0.3, dampingFraction: 0.3)){
                        animateImage = true
                    }
                }
            
            Spacer()
            
            PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                Label("Photo Library", systemImage: "photo.on.rectangle.angled")

            }
            .onChange(of: selectedPhoto) { newValue in
                Task{
                    do{
                        if let data = try await
                            newValue?.loadTransferable(type: Data.self){
                            if let uiImage  = UIImage(data: data){
                                bipimage = Image(uiImage: uiImage)
                            }
                        }
                    } catch {
                        print("😡 ERROR: loading failed\(error.localizedDescription)")
                    }
                }
            }
            
            
        }
        .padding()
    }
    
    func playSound(soundname: String){
        guard let soundFile = NSDataAsset(name: soundname) else {
            print("Could not read file named \(soundname)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        }catch{
            print("Error: \(error.localizedDescription) creating audioplayer")
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
