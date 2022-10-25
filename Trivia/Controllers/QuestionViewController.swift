//
//  QuestionViewController.swift
//  Trivia
//
//  Created by Stephen Walton on 10/7/22.
//

import UIKit

class QuestionViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    var gameModelController: GameController!
    var questions: [Question]!
    var currentCategory: Int! = -1
    var currentQuestion: Question!
    var currentQuestionNumber: Int = 0
    var questionButtons = [UIButton]()
    var score: Int = 0 {
        didSet {
            gameModelController.game.score = score
            scoreLabel.text = "Score: \(gameModelController.game.score.withCommas())"
            gameModelController.saveGameState()
        }
    }
    var correctAnswerCount = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)

        setUpHeaderAndFooter()
//        navigationController?.navigationBar.backgroundColor = UIColor.systemGreen
//        navigationController?.navigationBar.layer.opacity = 0.17
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressLabel.text = ""
        score = gameModelController.game.score
        nextQuestion()
    }

    private func setUpHeaderAndFooter() {
        scoreLabel.text = "Score: \(gameModelController.game.score.withCommas())"
        coinsLabel.text = "🪙 x\(gameModelController.game.coins.withCommas())"

        let starsLabelText = gameModelController.starsText[gameModelController.game.stars]
        starsLabel.text = gameModelController.starsText[gameModelController.game.stars]
        let searchChar = "☆"
        let starsLabelAttributedText = NSMutableAttributedString(string: starsLabelText ?? "")
        starsLabelAttributedText.attributeRangeFor(searchString: searchChar, attributeValue: UIFont(name: starsLabel.font.fontName, size: 17.0)!, attributeType: .Size, attributeSearchType: .All)
        starsLabel.attributedText = starsLabelAttributedText
    }

    func loadQuestion() {
        clearAnswers()
        questionLabel.text = String(htmlEncodedString: currentQuestion.question)
        difficultyLabel.text = "Difficulty: \(currentQuestion.difficulty.capitalized)"

        let height = 40
        var answers: [String] = currentQuestion.incorrect_answers
        answers.append(currentQuestion.correct_answer)
        answers.shuffle()
        var row = 0
        
        for answer in answers {
            let answerButton = UIButton(type: .system)
            answerButton.translatesAutoresizingMaskIntoConstraints = false
            answerButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            answerButton.setTitle(String(htmlEncodedString: answer), for: .normal)
            answerButton.addTarget(self, action: #selector(answerTapped), for: .touchUpInside)
            answerButton.layer.borderWidth = 1
            answerButton.layer.borderColor = UIColor.black.cgColor

            view.addSubview(answerButton)
            questionButtons.append(answerButton)
            
            NSLayoutConstraint.activate([
                answerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                answerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                answerButton.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: CGFloat(height * row + 10)),
            ])
            
            row += 1
        }
        
    }
    
    @objc func answerTapped(_ sender: UIButton) {
        guard let selectedAnswer = sender.titleLabel?.text else { return }
        var result: String!
        var correctAnswer: String!
        
        if selectedAnswer == String(htmlEncodedString: currentQuestion.correct_answer) {
            score += DifficultyPoints(rawValue: currentQuestion.difficulty)?.pointsValue ?? 0
            result = "Correct!"
            correctAnswer = ""
            if let progressText = progressLabel.text {
                progressLabel.text = progressText + "✓ "
            }
            correctAnswerCount += 1
        } else {
            result = "Incorrect!"
            correctAnswer = "Correct answer: \(String(htmlEncodedString: currentQuestion.correct_answer) ?? "")"
            if let progressText = progressLabel.text {
                progressLabel.text = progressText + "ⅹ "
            }
        }

        // Calls extension to set size and color or certain characters in string.  This is necessary because the checkmark and x are different sizes and colors.  Results get assigned to progressLabel.
        let searchChar = "ⅹ"
        let progressLabelAttributedText = NSMutableAttributedString(string: progressLabel.text ?? "")
        progressLabelAttributedText.attributeRangeFor(searchString: searchChar, attributeValue: UIColor.red, attributeType: .Color, attributeSearchType: .All)
        progressLabelAttributedText.attributeRangeFor(searchString: searchChar, attributeValue: UIFont(name: progressLabel.font.fontName, size: 24.0)!, attributeType: .Size, attributeSearchType: .All)
        progressLabel.attributedText = progressLabelAttributedText

        let ac = UIAlertController(title: result, message: correctAnswer, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: continueRound))
        present(ac, animated: true)
    }

    func continueRound(action: UIAlertAction) {
        nextQuestion()
    }
    
    func nextQuestion() {
        guard questions.count > 0 else {
            if correctAnswerCount >= 3 {
                gameModelController.game.categoriesCleared.append(gameModelController.game.categories[currentCategory])
                gameModelController.game.stars += 1
            }
            navigationController?.popViewController(animated: true)
            return
        }
        currentQuestion = questions.popLast()
        currentQuestionNumber += 1
        loadQuestion()
    }
    
    func clearAnswers() {
        for button in questionButtons {
            button.removeFromSuperview()
        }
    }
}
