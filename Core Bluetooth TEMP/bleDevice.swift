//
//  bleDeviceVC.swift
//  BLE_Temp
//
//  Created by Jimmy Pan on 2020/12/8.
//  Copyright © 2020 Andrew Jaffee. All rights reserved.
//

import UIKit

class bleDeviceVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let myDevice: [String] = ["Chairman", "MacBook", "iPhone6s", "Monx", "Samsung S2"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myDevice.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = myDevice[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Your selected is: \(myDevice[indexPath.row])")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
