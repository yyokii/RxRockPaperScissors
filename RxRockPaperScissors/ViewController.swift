//
//  ViewController.swift
//  RxRockPaperScissors
//
//  Created by Yoki Higashihara on 2018/10/18.
//  Copyright © 2018年 Yoki Higashihara. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class ViewController: UIViewController {
    
    @IBOutlet weak var myHandLabel: UILabel!
    @IBOutlet weak var opponentHandLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!

    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    @IBOutlet weak var scissorsButton: UIButton!

    private var viewModel: ViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        
        rockButton.rx.tap
            .subscribe { [unowned self] _ in
                // ボタンタップ時の処理
                self.setupViewModel()
            }
            .disposed(by: disposeBag)
    }
    
    private func setupViewModel() {
        let input = RxViewModelInput(
            rockButton: rockButton.rx.tap.asObservable(),
            paperButton: paperButton.rx.tap.asObservable(),
            scissorsButton: scissorsButton.rx.tap.asObservable()
        )
        viewModel = ViewModel(input: input)
        viewModel.outputs?.myHandText
            .bind(to: myHandLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.outputs?.opponentHandText
            .bind(to: opponentHandLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.outputs?.resultText
            .drive(resultLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

