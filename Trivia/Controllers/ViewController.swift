//
//  ViewController.swift
//  Trivia
//
//  Created by Stephen Walton on 10/7/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Inject current game
    var gameModelController: GameController!
    
    private var questions = [Question]()
    private var emojiFontSize = 0.0
    private var categories = [Category]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setUpHeaderAndFooter()
        title = ""
        
        // Any time we return, update the game state
        gameModelController.saveGameState()
        
        // Load categories
        categories = gameModelController.game.categories
        
        // Allow tapping if disabled elsewhere
        collectionView.isUserInteractionEnabled = true
        
        // Always get a fresh view, or load new level
        refreshDisplay()
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
    
    // Detect orientation change to force redraw
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape || UIDevice.current.orientation.isPortrait, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
            collectionView.reloadData()
        }
    }
        
    // Refresh view or load new level
    private func refreshDisplay() {
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
        // In ViewHelpers
        starsLabel.attributedText = getStarsAttributedText(numberOfStars: gameModelController.game.stars, font: UIFont(name: starsLabel.font.fontName, size: 17.0)!)
    }
    
    private func loadNextLevel() {
        gameModelController.loadNewLevel()
        collectionView.reloadData()
        setUpHeaderAndFooter()
    }
    
    private func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonQuestions = try? decoder.decode(Questions.self, from: json) {
            questions = jsonQuestions.results
        }
    }
}

// MARK: - UIViewController delegate
extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Want a square, only need width
        let width = view.frame.size.width
        let screenSize: CGRect = UIScreen.main.bounds
        if screenSize.width > screenSize.height {
            emojiFontSize = (width / 4) * 0.22
            return CGSize(width: width * 0.18, height: width * 0.18)
        } else {
            emojiFontSize = (width / 2) * 0.38
            return CGSize(width: width * 0.38, height: width * 0.38)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Need connection to proceed
        if gameModelController.game.has_connection != true {
            let ac = UIAlertController(title: "Connection not found!", message: "You need an internet connection to play Level Up Trivia. Please check your settings and try again." , preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(ac, animated: true)
            return
        }
        
        let category = categories[indexPath.row]
        
        DispatchQueue.main.async { [weak self] in
            collectionView.isUserInteractionEnabled = false
            if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "Question") as? QuestionViewController {
                vc.gameModelController = self?.gameModelController
                vc.currentCategory = category
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - UIViewController data source
extension ViewController: UICollectionViewDataSource {
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
            cell.layer.borderColor = UIColor(red: 213/255, green: 216/255, blue: 233/255, alpha: 1).cgColor
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

