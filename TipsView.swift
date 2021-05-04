//
//  TipsView.swift
//  Recycle.ai
//
//  Created by Maylin van Cleeff on 4/28/21.
//

import Foundation
import UIKit

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        // Generates the random tip as a UILabel
        let quotes = ["Because it has become increasingly challenging to find buyers for the recycled raw materials of plastics #3-7, even post recycling, these products will get stockpiled or sent to a landfill. Purchasing products in highly recyclable materials like glass, metal, and plastics #1-2 will help to reduce your environmental impact!", "Before you go grocery shopping, write down what you already have in your fridge and pantry. Plan meals around what food is going to spoil first!", "Save the peels of your carrots, garlic, onions, and celery to make your own vegetable stock!", "Freeze fruits and vegetables that you may not get to eating before they spoil!", "Invest in reusable water bottles and cloth bags to reduce purchases of single use plastic like plastic water bottles and plastic bags!", "Look for companies that offer warranties on their products!", "If feasible with dietary restrictions, reduce meat consumption when possible and try to commit to a day less a week of meat like meatless Mondays!", "Unplug appliances when they aren't being used and turn off the lights whenever you leave a room!", "85% of energy used to machine wash clothes goes to heating water. Try to wash clothes on cold when possible!", "When purchasing items from the grocery store, try to stray away from BPA-lined containers!", "Use leftover bathwater to water plants!", "Donate clothes that you no longer wear! Reuse old tee-shirts as cleaning rags!", "Switch the lightbulbs in your home to energy efficient types!", "Pay your bills online!", "Buy reusable razors over disposable ones!", "Try to buy non-toxic natural cleaning products instead of chemical based ones!", "Buy products without packaging whenever possible!", "Stray away from fast-fashion brands when you can!", "Bring your own coffee cup to coffee shops!"
          ]
        let randomNumber = Int.random(in: 0..<quotes.count)
        let aQuote = quotes[randomNumber]
        let label = UILabel()
        label.text = aQuote
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
        ])
        self.view = view
    }
}
