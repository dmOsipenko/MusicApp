//
//  CMTime+Extension.swift
//  MusicApp
//
//  Created by Дмитрий Осипенко on 30.08.21.
//

import Foundation
import AVKit

extension CMTime {
    func toDisplayString() -> String {
        guard !CMTimeGetSeconds(self).isNaN else {return ""}
        let totalSecond = Int(CMTimeGetSeconds(self))
        let seconds = totalSecond % 60
        let minutes = totalSecond / 60
        let timeFormatedString = String(format: "%02d:%02d", minutes, seconds)
        return timeFormatedString
    }
}
