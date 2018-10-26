//
//  ViewModel.swift
//  RxRockPaperScissors
//
//  Created by Yoki Higashihara on 2018/10/19.
//  Copyright © 2018年 Yoki Higashihara. All rights reserved.
//

import RxSwift
import RxCocoa

// ViewController に監視させる対象を定義
protocol RxViewModelOutput {
    // https://qiita.com/yuzushioh/items/0a4483502c5c8569790a
    var opponentHandText: Observable<String> { get }
    var myHandText: Observable<String> { get }
    var resultText: Driver<String> { get }
}

// ViewModel に継承させる protocol を定義
protocol RxViewModelType {
    var outputs: RxViewModelOutput? { get }
    init(input: RxViewModelInput)
}

// ボタンの入力シーケンス
struct RxViewModelInput {
    // Observable は翻訳すると観測可能という意味で文字どおり観測可能なものを表現するクラス
    let rockButton: Observable<Void>
    let paperButton: Observable<Void>
    let scissorsButton: Observable<Void>
}

class ViewModel: RxViewModelType{
    let opponentHandsArray = ["✊", "✌️", "🖐"]
    var outputs: RxViewModelOutput?
    
    private let myHandRelay = BehaviorRelay<String>(value: "✊")
    private let opponentHandRelay = BehaviorRelay<String>(value: "✊")
    
    private let disposeBag = DisposeBag()
    
    required init(input: RxViewModelInput) {
        self.outputs = self
        input.rockButton
            .subscribe(onNext: { [weak self] in
                self?.selectedRock()
                self?.selectOpponentHand()
            })
            .disposed(by: disposeBag)
        input.paperButton
            .subscribe(onNext: { [weak self] in
                self?.selectedPaper()
                self?.selectOpponentHand()
            })
            .disposed(by: disposeBag)
        input.scissorsButton
            .subscribe(onNext: { [weak self] in
                self?.selectedScissors()
                self?.selectOpponentHand()
            })
            .disposed(by: disposeBag)
    }
    
    private func selectedRock() {
        myHandRelay.accept("✊")
    }
    
    private func selectedScissors() {
        myHandRelay.accept("✌️")
    }
    
    private func selectedPaper() {
        myHandRelay.accept("🖐")
    }
    
    // あいての手をランダムに設定する
    private func selectOpponentHand() {
        print("selectOpponentValue 関数実行")
        let opponentHand = self.opponentHandsArray[Int(arc4random_uniform(3))]
        opponentHandRelay.accept(opponentHand)
    }
    
    // じゃんけんロジック
    private func rockScissorsPaper(myHand: String, opponentHand: String) -> String{
        if myHand == opponentHand {
            return "あいこ"
        } else {
            switch myHand {
            case "✊":
                return rockIsSelected(opponentHand: opponentHand)
            case "✌️":
                return scissorsIsSelected(opponentHand: opponentHand)
            case "🖐":
                return paperIsSelected(opponentHand: opponentHand)
            default:
                break
            }
        }
        return ""
    }
    
    private func rockIsSelected(opponentHand: String) -> String {
        if opponentHand == "✌️" {
            return "かちました"
        } else if opponentHand == "🖐" {
            return "まけました"
        }
        return ""
    }
    
    private func scissorsIsSelected(opponentHand: String) -> String {
        if opponentHand == "🖐" {
            return "かちました"
        } else if opponentHand == "✊" {
            return "まけました"
        }
        return ""
    }
    
    private func paperIsSelected(opponentHand: String) -> String {
        if opponentHand == "✊" {
            return "かちました"
        } else if opponentHand == "✌️" {
            return "まけました"
        }
        return ""
    }
}

extension ViewModel: RxViewModelOutput {
    var myHandText: Observable<String> {
        let myHandText = myHandRelay
            .map {
                "\($0)"
            }
            .debug("selectedValueText", trimOutput: false)
            .share(replay: 1)
        return myHandText
    }
    
    var opponentHandText: Observable<String> {
        let opponentValueText = opponentHandRelay
            .map {
                "\($0)"
            }
            .debug("opponentValueText", trimOutput: false)
            .share(replay: 1)
        
        return opponentValueText
    }
    
    var resultText: SharedSequence<DriverSharingStrategy, String> {
        let resultText = opponentHandRelay
            .map {[weak self] _ in
                (self?.rockScissorsPaper(myHand: (self?.myHandRelay.value)!, opponentHand: (self?.opponentHandRelay.value)!))!
            }
            .debug("resultText", trimOutput: false)
            .asDriver(onErrorJustReturn: "")
        return resultText
    }
}
