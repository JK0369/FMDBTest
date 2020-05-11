//
//  PickerController.swift
//  FMDBTest
//
//  Created by 김종권 on 2020/05/11.
//  Copyright © 2020 imustang. All rights reserved.
//

import UIKit
class PickerController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let departDAO = DepartmentDAO()
    var departList: [(departCd: Int, departTitle: String, departAddr: String)]!
    var pickerView: UIPickerView!
    
    // 현재 피커뷰에 선택되어 있는 부서의 코드를 가져옴
    var selectedDepartCd: Int {
        let row = self.pickerView.selectedRow(inComponent: 0)
        return self.departList[row].departCd
    }
    
    override func viewDidLoad() {
        self.departList = self.departDAO.find()
        
        self.pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.view.addSubview(self.pickerView)
        
        let pWidth = self.pickerView.frame.width
        let pHeight = self.pickerView.frame.height
        self.preferredContentSize = CGSize(width: pWidth, height: pHeight)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.departList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var titleView = view as? UITextView
        if titleView == nil {
            titleView = UITextView()
            titleView?.font = UIFont.systemFont(ofSize: 14)
            titleView?.textAlignment = .center
        }
        
        titleView?.text = "\(self.departList[row].departTitle)(\(self.departList[row].departAddr))"
        
        return titleView!
    }
}
