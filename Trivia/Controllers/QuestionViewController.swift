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
    @IBOutlet weak var progressLabel: UILabel!
    
    var gameModelController: GameController!
    var questions: [Question]!
    var currentCategory: Int! = -1
    var currentQuestion: Question!
    var currentQuestionNumber: Int = 0
    var answerButtons = [UIButton]()
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
        
        // The question
        questionLabel.text = String(htmlEncodedString: "\(currentQuestion.question)")

        // The API sends the correct answer and all incorrect answers.  Combine them into a single array and shuffle.
        var answers: [String] = currentQuestion.incorrect_answers
        answers.append(currentQuestion.correct_answer)
        answers.shuffle()
        
        // Save this to position next button. Buttons can vary in size,
        // this just saves the previous bottom anchor wherever it winds up being.
        var previousBottomAnchor = questionLabel.safeAreaLayoutGuide.bottomAnchor

        // Cycle through answers, create buttons and position them, and add them to answers array
        for answer in answers {
            // Some initial configuration
            var configuration = UIButton.Configuration.filled()
            configuration.background.backgroundColor = UIColor(red: CGFloat(119/255.0), green: CGFloat(168/255.0), blue: CGFloat(179/255.0), alpha: CGFloat(1.0))
            configuration.cornerStyle = .medium
            
            // New button for each answer
            let answerButton = UIButton(configuration: configuration, primaryAction: nil)
            // Some answers are long, need to word wrap
            answerButton.sizeToFit()
            // Config here
            answerButton.translatesAutoresizingMaskIntoConstraints = false
            
            // Set and configure button title
            answerButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            let answerText = String(htmlEncodedString: answer)
            answerButton.setTitle(answerText, for: .normal)
            answerButton.titleLabel?.numberOfLines = 0
            answerButton.titleLabel?.lineBreakMode = .byWordWrapping
            
            // Run answerTapped() when tapped
            answerButton.addTarget(self, action: #selector(answerTapped), for: .touchUpInside)

            // Append to answers array and add to view
            view.addSubview(answerButton)
            answerButtons.append(answerButton)
            
            // Anchors
            NSLayoutConstraint.activate([
                answerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                answerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                answerButton.topAnchor.constraint(equalTo: previousBottomAnchor, constant: 10),
            ])

            // Save this to position next button. Buttons can vary in size,
            // this just saves the previous bottom anchor wherever it winds up being.
            previousBottomAnchor = answerButton.safeAreaLayoutGuide.bottomAnchor
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
                gameModelController.game.coins += 1
            }
            navigationController?.popViewController(animated: true)
            return
        }
        currentQuestion = questions.popLast()
        currentQuestionNumber += 1
        loadQuestion()
    }
    
    func clearAnswers() {
        for button in answerButtons {
            button.removeFromSuperview()
        }
    }
}
