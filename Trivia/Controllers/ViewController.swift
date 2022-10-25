//
//  ViewController.swift
//  Trivia
//
//  Created by Stephen Walton on 10/7/22.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var questions = [Question]()
    var gameModelController: GameController!
    var categories = [Category]()
    var emojiFontSize = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setUpHeaderAndFooter()
        title = ""
        
        // Any time we return, update the game state
        gameModelController.saveGameState()
        
        // Always get a fresh view
        if gameModelController.game.stars < 5 {
            collectionView.reloadData()
        } else {
            // Move to next level
            loadNextLevel()
        }
        
    }
    
    private func setUpHeaderAndFooter() {
        scoreLabel.text = "Score: \(gameModelController.game.score.withCommas())"
        coinsLabel.text = "🪙 x\(gameModelController.game.coins.withCommas())"
        levelLabel.text = "Level \(gameModelController.game.currentLevel)"

        let starsLabelText = gameModelController.starsText[gameModelController.game.stars]
        let searchChar = "☆"
        let starsLabelAttributedText = NSMutableAttributedString(string: starsLabelText ?? "")
        starsLabelAttributedText.attributeRangeFor(searchString: searchChar, attributeValue: UIFont(name: starsLabel.font.fontName, size: 17.0)!, attributeType: .Size, attributeSearchType: .All)
        starsLabel.attributedText = starsLabelAttributedText
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func loadNextLevel() {
        gameModelController.loadNewLevel()
        collectionView.reloadData()
        setUpHeaderAndFooter()
    }

    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonQuestions = try? decoder.decode(Questions.self, from: json) {
            questions = jsonQuestions.results
        }
    }
    
    func loadRound(forCategory category: Int) {
        DispatchQueue.main.async { [weak self] in
            if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "Question") as? QuestionViewController {
                vc.currentCategory = category
                vc.questions = self?.questions
                vc.gameModelController = self?.gameModelController
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func showError() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading question; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIScreen.main.nativeBounds.width <= 800 {
            emojiFontSize = 60
            return CGSize(width: 120, height: 120)
        }
        
        emojiFontSize = 100
        return CGSize(width: 165, height: 165)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categoryId = categories[indexPath.row].id
        
        let urlString: String
        
        urlString = "https://opentdb.com/api.php?category=\(categoryId)&amount=5&difficulty=\(gameModelController.getCurrentLevelDifficulty())&token=\(gameModelController.game.token)"
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    self?.loadRound(forCategory: indexPath.row)
                    return
                }
            }
            self?.showError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Category", for: indexPath) as? CategoryCell else {
            fatalError("Unable to dequeue CategoryCell")
        }
        
        if gameModelController.game.categoriesCleared.contains(gameModelController.game.categories[indexPath.row]) {
            cell.isUserInteractionEnabled = false
            cell.lockView.isHidden = false
            cell.layer.borderColor = UIColor.systemGray.cgColor
        } else {
            cell.isUserInteractionEnabled = true
            cell.lockView.isHidden = true
            cell.layer.borderColor = UIColor.systemGreen.cgColor
            cell.layer.backgroundColor = UIColor.white.cgColor
        }

        cell.layer.borderWidth = 1
        cell.isSelected = true

        cell.textLabel.text = categories[indexPath.row].name
        cell.image.text = categories[indexPath.row].image

        let fontSize = CGFloat(emojiFontSize)
        cell.image.font = cell.image.font.withSize(fontSize)
        
        cell.tag = categories[indexPath.row].id
        
        return cell
    }
}

