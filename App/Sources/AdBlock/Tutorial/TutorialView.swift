//
//  TutorialView.swift
//  MagicSecurity
//
//  Created by User on 14.04.25.
//

import SwiftUI
import ComposableArchitecture
import AVKit

/*
 TODO:
 Add gif
 */

public struct TutorialView: View {
    let store: StoreOf<Tutorial>
    
    public init(store: StoreOf<Tutorial>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 42) {
            VStack(alignment: .leading) {
                HStack {
                    TutorialStepView(
                        text: "open_settings_app".localized,
                        isSelected: false
                    )
                    
                    TutorialStepView(
                        text: "tap_safari".localized,
                        isSelected: false
                    )
                }
                
                HStack {
                    TutorialStepView(
                        text: "select_extensions".localized,
                        isSelected: false,
                    )
                    
                    TutorialStepView(
                        text: "app_name".localized,
                        isSelected: true,
                    )
                }
            }
            .padding(.horizontal)
            
            VideoPlayerView(
                url: Bundle.main.url(forResource: "tutor_video", withExtension: "mp4")!,
                contentMode: .resizeAspect
            )
            .frame(width: 280, height: videoLayerHeight)
            .clipped()
            
            RoundedButton(buttonText: "open_settings".localized) {
                store.send(.openSettingsTapped)
            }
            
            Spacer()
        }
        .padding(.top)
        .navigationTitle("tutorial".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("skip".localized.localizedUppercase) {
                    store.send(.skipTapped)
                }
            }
        }
    }
    
    var videoLayerHeight: CGFloat {
        if UIDevice.isSE || UIDevice.isPad {
            return 280
        } else {
            return 380
        }
    }
}

struct VideoPlayerView: UIViewRepresentable {
    let url: URL
    let contentMode: AVLayerVideoGravity
    
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(url: url, gravity: contentMode)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private let player: AVPlayer
    
    init(url: URL, gravity: AVLayerVideoGravity) {
        self.player = AVPlayer(url: url)
        super.init(frame: .zero)
        
        playerLayer.player = player
        playerLayer.videoGravity = gravity
        layer.addSublayer(playerLayer)
        
        player.play()
        player.isMuted = true
        player.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    NavigationStack {
        TutorialView(
            store: Store(
                initialState: Tutorial.State()
            ) {
                Tutorial()
            }
        )
    }
}
