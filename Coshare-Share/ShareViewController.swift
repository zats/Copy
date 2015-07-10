//
//  ShareViewController.swift
//  Coshare-Share
//
//  Created by Sash Zats on 7/6/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import Cocoa

class ShareViewController: NSViewController {

    let xerox = Xerox()
    
    override var nibName: String? {
        return "ShareViewController"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        copyItem{ success in
            fatalError()
        }
    }
    
    private func copyItem(completion: (Bool -> Void)? = nil) {
        guard let context = self.extensionContext else {
            fatalError("No context provided!")
        }
        
        guard let items = context.inputItems as? [NSExtensionItem] else {
            fatalError("Input items are not of type NSExtensionItem: \(context.inputItems)")
        }
        xerox.copy(items) { success in
            if let completion = completion {
                completion(success)
            }
        }
    }

}
