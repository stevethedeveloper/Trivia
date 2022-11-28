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
    @IBOutlet var contentView: UIView!
    
    var gameModelController: GameController!
    var currentCategory: Category!
    var questions = [Question]()
    
    private var currentQuestion: Question!
    private var currentQuestionNumber: Int = 0
    private var answerButtons = [UIButton]()
    private var correctAnswerCount = 0
    // For the "buy" functionality
    private var numberOfAnswersToRemove = 0
    private var buyButton = UIButton()
    
    // Update the score label and save the state
    private var score: Int = 0 {
        didSet {
            gameModelController.game.score = score
            scoreLabel.text = "Score: \(gameModelController.game.score.withCommas())"
            gameModelController.saveGameState()
        }
    }
    
    // Loading view
    private let loaderView = RoundLoaderViewController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        loadQuestions(forCategory: currentCategory.id)
        
        setUpHeaderAndFooter()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressLabel.text = ""
        score = gameModelController.game.score
    }
    
    private func setUpHeaderAndFooter() {
        // Update score and coin labels
        scoreLabel.text = "Score: \(gameModelController.game.score.withCommas())"
        coinsLabel.text = "🪙 x\(gameModelController.game.coins.withCommas())"
        // In ViewHelpers
        starsLabel.attributedText = getStarsAttributedText(numberOfStars: gameModelController.game.stars, font: UIFont(name: starsLabel.font.fontName, size: 17.0)!)
    }
        
    private func createLoaderView() {
        loaderView.text = currentCategory.image
        // add the loader view view controller
        addChild(loaderView)
        loaderView.view.frame = view.frame
        view.addSubview(loaderView.view)
        loaderView.didMove(toParent: self)
    }
    
    private func newToken(reloadQuestions: Bool = true) {
        gameModelController.getToken()
        loadQuestions(forCategory: currentCategory.id)
    }
    
    private func loadQuestions(forCategory category: Int) {
        // Show loading screen
        createLoaderView()
        
        var urlString: String
        
        urlString = "https://opentdb.com/api.php?category=\(category)&amount=5&difficulty=\(gameModelController.getCurrentLevelDifficulty())&token=\(gameModelController.game.token)"
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    if self?.parse(json: data) == true {
                        // Hide loader view
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.nextQuestion()
                            self?.loaderView.view.removeFromSuperview()
                            self?.loaderView.removeFromParent()
                        }
                        return
                    } else {
                        // If no results are returned, get a new token, the newToken method will
                        // repeat the call to this function
                        self?.newToken()
                        return
                    }
                }
            }
        }
    }
    
    private func parse(json: Data) -> Bool {
        let decoder = JSONDecoder()
        
        if let jsonQuestions = try? decoder.decode(Questions.self, from: json) {
            questions = jsonQuestions.results
            if jsonQuestions.response_code == 3 || jsonQuestions.response_code == 4 {
                // bad token
                return false
            }
            gameModelController.game.response_code = jsonQuestions.response_code
        }
        
        return true
    }
    
    private func loadQuestion() {
        // The question
        questionLabel.text = String(htmlEncodedString: "\(currentQuestion.question)")
        
        loadAnswers()
    }
    
    /*
     This method sets up the answer buttons in code. There are two types of questions: mutliple choice and true/false.
     Multiple choice also gets the "buy" button to allow them to trade coins for narrowing the answers.
     True/false does not get a "buy" button, because that would reveal the answer.
     */
    private func loadAnswers() {
        clearAnswers()
        
        // The API sends the correct answer and all incorrect answers.  Combine them into a single array and shuffle.
        let answers: [String] = getAnswersArray()
        
        // Save this to position next button. Buttons can vary in size,
        // this just saves the previous bottom anchor wherever it winds up being.
        var previousBottomAnchor = questionLabel.safeAreaLayoutGuide.bottomAnchor
        
        // Cycle through answers, create buttons and position them, and add them to answers array
        for answer in answers {
            // Some initial configuration
            var configuration = UIButton.Configuration.plain()
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .systemFont(ofSize: 22)
                return outgoing
            }
            configuration.background.backgroundColor = UIColor(red: 67/255, green: 85/255, blue: 168/255, alpha: 1)
            configuration.cornerStyle = .capsule
            configuration.buttonSize = .large
            
            // New button for each answer
            let answerButton = UIButton(configuration: configuration, primaryAction: nil)
            // Some answers are long, need to word wrap
            answerButton.sizeToFit()
            // Config in code
            answerButton.translatesAutoresizingMaskIntoConstraints = false

            answerButton.setTitleColor(.white, for: .normal)
            
            // Set and configure button title
            let answerText = String(htmlEncodedString: answer)
            answerButton.setTitle(answerText, for: .normal)
            answerButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            answerButton.titleLabel?.numberOfLines = 0
            answerButton.titleLabel?.lineBreakMode = .byWordWrapping
            
            // Run answerTapped() when tapped
            answerButton.addTarget(self, action: #selector(answerTapped), for: .touchUpInside)
            
            // Append to answers array and add to view
            contentView.addSubview(answerButton)
            answerButton.layer.zPosition = -1
            
            answerButtons.append(answerButton)
            
            // Anchors
            NSLayoutConstraint.activate([
                answerButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                answerButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                answerButton.topAnchor.constraint(equalTo: previousBottomAnchor, constant: 20),
            ])
            
            // Save this to position next button. Buttons can vary in size,
            // this just saves the previous bottom anchor wherever it winds up being.
            previousBottomAnchor = answerButton.safeAreaLayoutGuide.bottomAnchor
        }
        
        // Add a button so they can buy help with question
        if currentQuestion.type == "multiple" {
            var configuration = UIButton.Configuration.plain()
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .systemFont(ofSize: 17)
                return outgoing
            }
            configuration.background.backgroundColor = UIColor(red: CGFloat(255/255.0), green: CGFloat(0/255.0), blue: CGFloat(0/255.0), alpha: CGFloat(1.0))
            configuration.cornerStyle = .capsule
            
            
            buyButton.translatesAutoresizingMaskIntoConstraints = false
            buyButton.configuration = configuration
            buyButton.sizeToFit()
            buyButton.setTitleColor(.white, for: .normal)

            buyButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            buyButton.setTitle("🪙 Remove 2 incorrect answers for 2 coins!", for: .normal)
            buyButton.titleLabel?.numberOfLines = 1
            buyButton.addTarget(self, action: #selector(buyHelp), for: .touchUpInside)
            contentView.addSubview(buyButton)
            buyButton.layer.zPosition = -1
            
            // Anchors
            NSLayoutConstraint.activate([
                buyButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                buyButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                buyButton.topAnchor.constraint(greaterThanOrEqualTo: previousBottomAnchor, constant: 40),
                buyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
        }
    }
    
    private func getAnswersArray() -> [String] {
        var answers: [String] = currentQuestion.incorrect_answers
        answers.append(currentQuestion.correct_answer)
        answers.shuffle()
        
        return answers
    }
    
    @objc private func buyHelp() {
        if gameModelController.game.coins < 2 {
            let ac = UIAlertController(title: "Sorry!", message: "You don't have enough coins! Get more coins by completing categories." , preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Need help?", message: "You can remove two (2) incorrect answers for two (2) coins!" , preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: completeBuy))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(ac, animated: true)
        }
    }
    
    private func completeBuy(action: UIAlertAction) {
        numberOfAnswersToRemove = 2
        for button in answerButtons where currentQuestion.correct_answer != button.titleLabel?.text ?? "" && numberOfAnswersToRemove > 0 {
            button.isEnabled = false
            button.configuration?.background.backgroundColor = .gray
            
            numberOfAnswersToRemove -= 1
        }
        gameModelController.game.coins -= 2
        coinsLabel.text = "🪙 x\(gameModelController.game.coins.withCommas())"
    }
    
    @objc private func answerTapped(_ sender: UIButton) {
        guard let selectedAnswer = sender.titleLabel?.text else { return }
        var result: String!
        var correctAnswer: String!
        
        let isCorrect = checkAnswer(submittedAnswer: selectedAnswer, expectedAnswer: String(htmlEncodedString: currentQuestion.correct_answer) ?? "")
        
        if isCorrect {
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
    
    private func checkAnswer(submittedAnswer: String, expectedAnswer: String) -> Bool {
        return submittedAnswer == expectedAnswer
    }
    
    private func continueRound(action: UIAlertAction) {
        nextQuestion()
    }
    
    private func nextQuestion() {
        guard questions.count > 0 else {
            if correctAnswerCount >= 3 {
                guard let index = gameModelController.game.categories.firstIndex(where: {$0.id == currentCategory.id}) else {
                    return
                }
                gameModelController.game.categoriesCleared.append(gameModelController.game.categories[index])
                gameModelController.game.stars += 1
                gameModelController.game.coins += 1
            }
            navigationController?.popViewController(animated: true)
            return
        }
        numberOfAnswersToRemove = 0
        currentQuestion = questions.popLast()
        currentQuestionNumber += 1
        loadQuestion()
    }
    
    private func clearAnswers() {
        for button in answerButtons {
            button.removeFromSuperview()
        }
        answerButtons.removeAll()
        buyButton.removeFromSuperview()
    }
}
