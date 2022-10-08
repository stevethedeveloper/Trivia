//
//  ViewController.swift
//  Trivia
//
//  Created by Stephen Walton on 10/7/22.
//

import UIKit

class ViewController: UIViewController {
    var questions = [Question]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    func showError() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }

    @IBAction func startTapped(_ sender: UIButton) {
        let urlString: String
        
        urlString = "https://opentdb.com/api.php?amount=10"
        
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
}

