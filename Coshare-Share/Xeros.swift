//
//  Xeros.swift
//  Copy
//
//  Created by Sash Zats on 7/9/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import AppKit

public class Xerox {
    public init() {
        
    }
    
    public func copy(extensionItems: [NSExtensionItem], completion: (Bool -> Void)) {
        

        var pasteboardItems:[NSPasteboardWriting] = extensionItems.flatMap{ return $0.attributedContentText }

        let group = dispatch_group_create()
        let attachments: [NSItemProvider] = extensionItems.flatMap{ $0.attachments as! [NSItemProvider] }
        for attachment in attachments {
            
            // Image
            attachment.typedAccess(kUTTypeImage, group) { obj in
                if let URL = obj as? NSURL {
                    pasteboardItems.append(URL)
                } else if let image = obj as? NSImage {
                    pasteboardItems.append(image)
                } else if let data = obj as? NSData, let image = NSImage(data: data) {
                    pasteboardItems.append(image)
                }
            }
            
            // Files / folders
            let isUTFileItem = attachment.typedAccess(kUTTypeItem, group) { obj in
                if let URL = obj as? NSURL {
                    pasteboardItems.append(URL)
                }
            }
            // Not a file
            if !isUTFileItem {
                // URL
                attachment.typedAccess(kUTTypeURL, group) { obj in
                    if let URL = obj as? NSURL {
                        pasteboardItems.append(URL)
                    }
                }
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            let pasteboard = NSPasteboard.generalPasteboard()
            pasteboard.clearContents()
            let success = pasteboard.writeObjects(pasteboardItems)
            completion(success)
        }
    }
}

extension NSItemProvider {
    func typedAccess(UTType: CFStringRef, _ group: dispatch_group_t, block: AnyObject -> Void) -> Bool {
        guard self.hasItemConformingToTypeIdentifier(UTType as String) else {
            return false
        }
        dispatch_group_enter(group)
        self.loadItemForTypeIdentifier(UTType as String, options: nil) { obj, err in
            block(obj)
            dispatch_group_leave(group)
        }
        return true
    }
}






















