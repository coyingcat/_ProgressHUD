//
//  ProgressHub.swift
//  musicSheet
//
//  Created by Jz D on 2019/9/6.
//  Copyright © 2019 Jz D. All rights reserved.
//

import UIKit


func getWindow() -> UIView?{
    let windows = UIApplication.shared.windows
    if let vue = windows.first{
        return vue
    }
    return nil
}


extension ProgressHUD{
    
    
    static func show() -> ProgressHUD?{
        guard let view = getWindow() else{
            return nil
        }
        let hud = ProgressHUD.showAdded(to: view)
        return hud
    }
    
    
    @discardableResult
    static func show(_ message: String) -> ProgressHUD?{
        guard let view = getWindow(), message != "" else{
            return nil
        }
        let hud = ProgressHUD.showAdded(to: view)
        hud.label.text = message
        hud.customView = nil
        hud.mode = ProgressHUDMode.customView
        hud.hide(afterDelay: 1)
        return hud
    }
    
    func hide(){
        hideAnimated()
    }
    
}
