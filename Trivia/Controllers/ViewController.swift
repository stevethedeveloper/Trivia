//
//  ViewController.swift
//  Trivia
//
//  Created by Stephen Walton on 10/7/22.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var scoreLabel: UILabel!
    
    var questions = [Question]()
    var gameModelController: GameController!
    var categories = [Category]()
    var emojiFontSizeConstant = 0
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        scoreLabel.text = "Score: \(gameModelController.game.score.withCommas())"
        title = ""
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
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonQuestions = try? decoder.decode(Questions.self, from: json) {
            questions = jsonQuestions.results
        }
    }
    
    func loadRound() {
        DispatchQueue.main.async { [weak self] in
            if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "Question") as? QuestionViewController {
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
    
    func startTapped(_ sender: UIButton) {
        let urlString: String
        
        print(sender.tag)
        
        urlString = "https://opentdb.com/api.php?amount=3&token=\(gameModelController.game.token)"
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    self?.loadRound()
                    return
                }
            }
            self?.showError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIScreen.main.nativeBounds.width <= 800 {
            emojiFontSizeConstant = -60
            return CGSize(width: 120, height: 120)
        }
        
        emojiFontSizeConstant = 0
        return CGSize(width: 165, height: 165)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categoryId = categories[indexPath.row].id
        
        let urlString: String
        
        urlString = "https://opentdb.com/api.php?category=\(categoryId)&amount=3&token=\(gameModelController.game.token)"
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    self?.loadRound()
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
        
        if indexPath.row > 3 {
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
        print(cell.image.frame.width)
        let fontSize = cell.image.frame.width + CGFloat(emojiFontSizeConstant)
        cell.image.font = cell.image.font.withSize(fontSize)
        
        cell.tag = categories[indexPath.row].id
        
        return cell
    }
}

