import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    var player: AVAudioPlayer?

    func playBackgroundMusic() {
        // 确保这里的文件名与实际文件名一致
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else {
            print("Background music file not found")
            return
        }
        
        do {
            // 设置音频会话类别
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // 循环播放
            player?.play()
        } catch {
            print("Error playing background music: \(error.localizedDescription)")
        }
    }

    func playSoundEffect(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        do {
            let soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer.play()
        } catch {
            print("Error playing sound effect: \(error.localizedDescription)")
        }
    }
}
