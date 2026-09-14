//
//  Constants.swift
//  SSMVPlayer
//
//  Created by natha on 6/4/26.
// #TODO: make an appconstants enum

import SwiftUI

let DEBUG_MODE = false

let ALL_EXISTING_SONGS: [String] =  [
    "つぼみ",
    "恋が咲く季節",
    "夢をのぞいたら（for BEST3 VERSION）",
    "Brand new!",
    "Never ends",
    "Let’s Sail Away!!!",
    "VOY@GER",
    "ダンス・ダンス・ダンス",
    "Orange Sapphire",
    "オルゴールの小箱",
    "認めてくれなくたっていいよ",
    "ツインテールの風",
    "とんでいっちゃいたいの",
    "躍るFLAGSHIP",
    "Athanasia",
    "印象",
    "イケナイGO AHEAD",
    "生存本能ヴァルキュリア",
    "Love∞Destiny",
    "クレイジークレイジー",
    "Pretty Liar",
    "Starry-Go-Round",
    "O-Ku-Ri-Mo-No Sunday!",
    "無重力シャトル",
    "バベル",
    "TRUE COLORS",
    "Gossip Club",
    "幸せの法則 ～ルール～",
    "オレンジタイム",
    "Secret Mirage",
    "レッド・ソール",
    "Drastic Melody",
    "UNIQU3 VOICES!!!",
    "ジュビリー",
    "We wish your smile",
    "Never say never",
    "ヴィーナスシンドローム",
    "TOKIMEKIエスカレート",
    "エヴリデイドリーム",
    "Bright Blue",
    "お散歩カメラ",
    "2nd SIDE",
    "薄荷 -ハッカ-",
    "青の一番星",
    "こいかぜ -花葉-",
    "One Life",
    "Last Kiss",
    "もりのくにから",
    "Claw My Heart",
    "14平米にスーベニア",
    "トキメキは赤くて甘い",
    "ステップ！",
    "Frozen Tears",
    "薄紅",
    "夕映えプレゼント",
    "Memories",
    "この空の下",
    "Trancing Pulse",
    "心もよう",
    "M@GIC☆",
    "shabon song",
    "ささのはに、うたかたに。",
    "サマーサイダー"
]


let SONG_QUOTAS: [String: Int] = [
    "つぼみ": 8,
    "恋が咲く季節": 1,
    "夢をのぞいたら（for BEST3 VERSION）": 36,
    "Brand new!": 3,
    "Let’s Sail Away!!!": 3,
    "ダンス・ダンス・ダンス": 2,
    "Orange Sapphire": 1,
    "オルゴールの小箱": 1,
    "認めてくれなくたっていいよ": 1,
    "ツインテールの風": 3,
    "躍るFLAGSHIP": 3,
    "Athanasia": 3,
    "生存本能ヴァルキュリア": 1,
    "Love∞Destiny": 1,
    "クレイジークレイジー": 2,
    "Pretty Liar": 8,
    "Starry-Go-Round": 1,
    "O-Ku-Ri-Mo-No Sunday!": 1,
    "バベル": 2,
    "TRUE COLORS": 1,
    "Gossip Club": 3,
    "オレンジタイム": 3,
    "レッド・ソール": 1,
    "Drastic Melody": 3,
    "UNIQU3 VOICES!!!": 3,
    "ジュビリー": 8,
    "We wish your smile›": 8,
    "Never say never": 2,
    "ヴィーナスシンドローム": 2,
    "TOKIMEKIエスカレート": 1,
    "エヴリデイドリーム": 1,
    "Bright Blue": 1,
    "お散歩カメラ": 1,
    "2nd SIDE": 1,
    "薄荷 -ハッカ-": 1,
    "青の一番星": 3,
    "こいかぜ -花葉-": 5,
    "One Life": 5,
    "Last Kiss": 5,
    "もりのくにから": 1,
    "Claw My Heart": 1,
    "14平米にスーベニア": 1,
    "トキメキは赤くて甘い": 1,
    "ステップ！": 1,
    "Frozen Tears": 1,
    "薄紅": 1,
    "夕映えプレゼント": 1,
    "この空の下": 2,
    "Trancing Pulse": 3,
    "心もよう": 3,
    "M@GIC☆": 1,
    "shabon song": 1
]

extension Color {
    static let customWhite  = Color(red: 254/255, green: 254/255, blue: 254/255)
    static let customRed    = Color(red: 254/255, green: 48/255,  blue: 129/255)
    static let customBlue   = Color(red: 13/255,  green: 114/255, blue: 254/255)
    static let customOrange = Color(red: 254/255, green: 170/255, blue: 17/255)
    static let customBlack  = Color(red: 65/255,  green: 65/255,  blue: 65/255)
    static let customGray = Color(red: 220/255,  green: 220/255,  blue: 220/255)
    static let customPink = Color(red: 254/255,  green: 178/255,  blue: 233/255)
    static let customDarkGray = Color(red: 196/255, green: 196/255, blue: 196/255)
    static let customSkyBlue = Color(red: 135/255, green: 206/255, blue: 250/255)
}

func colorFromAttribute(_ att: String) -> Color {
    if att == "cute" { return .customRed }
    if att == "cool" { return .customBlue }
    if att == "passion" { return .customOrange }
    return .customBlack
}
