//
//  bleDeviceVC.swift
//  BLE_Temp
//
//  Created by Jimmy Pan on 2020/12/8.
//  Copyright © 2020 Andrew Jaffee. All rights reserved.
//

import UIKit

class bleDeviceVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    var dataToBeSend = "999999"
    
    @IBAction func clickDismiss(_ sender: Any) {

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension bleDeviceVC: FetchTextDelegate{
    func fetchText(_ text: String){
        print(text)
    }
}
