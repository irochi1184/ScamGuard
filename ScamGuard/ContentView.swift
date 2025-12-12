//
//  ContentView.swift
//  ScamGuard
//
//  Created by 有田健一郎 on 2025/12/12.
//

import SwiftUI

struct ScamNumber: Identifiable {
    let id = UUID()
    let number: String
    let label: String
    let source: String
    let isInternational: Bool
    let lastUpdated: String
}

struct ContentView: View {
    @StateObject private var logic = ScamLogicEngine()
    @State private var blockInternational = true
    @State private var blockPoliceList = true
    @State private var aiCallDetection = true
    @State private var showCallWarnings = true
    @State private var autoReport = false
    @State private var notifyCrimeNews = true
    @State private var simulationNumber = ""
    @State private var simulationTranscript = ""
    @State private var simulationInternational = false
    @State private var evaluationResult: CallEvaluationResult?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    statusCards
                    controlPanel
                    policeListSection
                    aiDetectionSection
                    simulationSection
                    notificationSection
                    tipsSection
                }
                .padding()
            }
            .navigationTitle("警察庁推奨アプリ案")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("特殊詐欺の未然防止を目指すスマホアプリのUI案です。")
                .font(.headline)
            Text("国際電話や警察庁提供リストに載った番号からの着信を遮断し、AIで詐欺通話を検知する流れを再現しています。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var statusCards: some View {
        HStack(spacing: 16) {
            statusCard(title: "直近被害額", value: "約1097億円", detail: "今年1〜10月（暫定）")
            statusCard(title: "遮断強化", value: "国際番号＋警察庁リスト", detail: "課題だった国際番号を重点対策")
        }
    }

    private func statusCard(title: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3).bold()
            Text(detail).font(.footnote).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("着信制限", systemImage: "shield.lefthalf.filled")
                    .font(.headline)
                Spacer()
                Text("無料提供・推奨条件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            toggleRow(title: "国際電話（＋番号）を自動遮断", isOn: $blockInternational, description: "携帯へ多い国際番号経由の詐欺電話を即遮断")
            toggleRow(title: "警察庁提供リストを遮断", isOn: $blockPoliceList, description: "最新の詐欺電話番号リストで着信・発信を制限")
            toggleRow(title: "AIで詐欺通話を自動検知", isOn: $aiCallDetection, description: "通話音声をリアルタイム解析し警告画面を表示")
            toggleRow(title: "警告ポップアップを表示", isOn: $showCallWarnings, description: "遮断できなかった場合も注意喚起を徹底")
            toggleRow(title: "自動で警察へ報告", isOn: $autoReport, description: "ユーザー同意後に疑い通話を匿名共有")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func toggleRow(title: String, isOn: Binding<Bool>, description: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Toggle(isOn: isOn) {
                    Text(title).font(.body)
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 2)
        }
        .padding(.vertical, 4)
    }

    private var policeListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("警察庁提供リスト", systemImage: "exclamationmark.bubble")
                    .font(.headline)
                Spacer()
                Text("最新更新: 11/11")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(logic.policeListedNumbers) { item in
                ScamNumberRow(number: item)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var aiDetectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("AI自動検知ログ", systemImage: "waveform.badge.exclamationmark")
                    .font(.headline)
                Spacer()
                Text("通話中の声質・文面を解析")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(logic.aiDetections) { item in
                ScamNumberRow(number: item)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var simulationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("着信評価シミュレーション", systemImage: "phone.connection")
                    .font(.headline)
                Spacer()
                Text("ロジックの想定動作を確認")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                TextField("電話番号を入力", text: $simulationNumber)
                    .textFieldStyle(.roundedBorder)
                TextField("通話で聞こえた文面を貼り付け (例: 口座確認コード)", text: $simulationTranscript, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)

                Toggle(isOn: $simulationInternational) {
                    Text("国際番号として評価")
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))

                Button(action: simulateCall) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("評価する")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(simulationNumber.isEmpty)
            }

            if let result = evaluationResult {
                resultView(result)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func resultView(_ result: CallEvaluationResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("判定: \(result.action.rawValue)")
                    .font(.headline)
                Spacer()
                Text(result.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("理由")
                    .font(.subheadline)
                    .bold()
                ForEach(result.reasons, id: \.self) { reason in
                    bullet(reason)
                }
            }

            if !result.notifications.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("通知・処理")
                        .font(.subheadline)
                        .bold()
                    ForEach(result.notifications, id: \.self) { note in
                        bullet(note)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.05)))
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("防犯情報の通知", systemImage: "bell.badge")
                    .font(.headline)
                Spacer()
            }

            toggleRow(title: "地域の防犯情報を受信", isOn: $notifyCrimeNews, description: "自治体・警察の速報をプッシュ通知")

            VStack(alignment: .leading, spacing: 8) {
                Text("通知サンプル")
                    .font(.subheadline)
                    .bold()
                bullet("市内で還付金詐欺の予兆通話が連続発生。警察を名乗る不審な国際番号に注意。")
                bullet("金融機関を装ったアカウント確認のSMSに応じないでください。")
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("利用のポイント", systemImage: "checkmark.seal")
                    .font(.headline)
                Spacer()
            }
            bullet("遮断と警告を併用し、詐欺電話の入り口対策を強化")
            bullet("警察庁推奨アプリとしてロゴ・名称を表示し、安心感を提供")
            bullet("ユーザーからの匿名報告を活用し、リスト更新を高速化")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(Color.blue).frame(width: 6, height: 6).padding(.top, 5)
            Text(text).font(.footnote).foregroundStyle(.secondary)
        }
    }

    private func simulateCall() {
        evaluationResult = logic.evaluateCall(
            number: simulationNumber,
            isInternational: simulationInternational,
            transcript: simulationTranscript,
            blockInternational: blockInternational,
            blockPoliceList: blockPoliceList,
            aiDetection: aiCallDetection,
            showWarnings: showCallWarnings,
            autoReport: autoReport
        )
    }
}

struct ScamNumberRow: View {
    let number: ScamNumber

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(number.number)
                    .font(.body)
                    .bold()
                Text(number.label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("ソース: \(number.source)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(number.isInternational ? "国際" : "国内")
                    .font(.caption2)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(number.isInternational ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                    .foregroundStyle(number.isInternational ? .red : .blue)
                    .clipShape(Capsule())
                Text(number.lastUpdated)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        Divider()
    }
}

#Preview {
    ContentView()
}
