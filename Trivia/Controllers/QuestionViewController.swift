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
    @IBOutlet weak var difficultyLabel: UILabel!
    
    var gameModelController: GameController!
    var questions: [Question]!
    var currentQuestion: Question!
    var currentQuestionNumber: Int = 0
    var questionButtons = [UIButton]()
    var score: Int = 0 {
        didSet {
            gameModelController.game.score = score
            scoreLabel.text = "Score: \(gameModelController.game.score.withCommas())"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        score = gameModelController.game.score
        nextQuestion()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        } else {
            result = "Incorrect!"
            correctAnswer = "Correct answer: \(String(htmlEncodedString: currentQuestion.correct_answer) ?? "")"
        }

        let ac = UIAlertController(title: result, message: correctAnswer, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: continueRound))
        present(ac, animated: true)

//        nextQuestion()
    }

    func continueRound(action: UIAlertAction) {
        nextQuestion()
    }
    
    func nextQuestion() {
        guard questions.count > 0 else {
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
