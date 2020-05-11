//
//  DepartmentListVC.swift
//  FMDBTest
//
//  Created by 김종권 on 2020/05/10.
//  Copyright © 2020 imustang. All rights reserved.
//

import UIKit
class DepartmentListVC: UITableViewController {
    var departList: [(departCd: Int, departTitle: String, departAddr: String)]!
    let departDAO = DepartmentDAO()
    
    override func viewDidLoad() {
        self.departList = self.departDAO.find() /// DAO객체 통해 해당 클래스의 heap할당 변수에 저장
        self.initUI() /// 테이블 뷰에 표시
    }
    
    func initUI() {
        
        // 네비게이션 타이틀
        let navTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        navTitle.font = .systemFont(ofSize: 14)
        navTitle.text = "부서 목록 \n" + " 총 \(self.departList.count) 개"
        
        // 네비게이션 바 UI
        self.navigationItem.titleView = navTitle
        
         /// 네비게이션바에 왼쪽상단에 Edit이라는 버튼, 셀을 삭제할 수 있는 편집 모드가 구현된 버튼
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // 일반 버튼에 편집 모드를 설정하려면 다음 이벤트 추가
        /*
         @objc func editing(_ sender: Any) {
            self.tableView.setEditing(true, animated: true) // 선택
            self.tableView.allowsSelectionDuringEditing = true // 스와이프
         }
         */
    }
    
    @IBAction func add(_ sender: Any) {
        let alert = UIAlertController(title: "신규 등록 부서", message: "신규 부서를 등록해 주세요", preferredStyle: .alert)
        
        alert.addTextField() { (tf) in tf.placeholder = "부서명" }
        alert.addTextField() { (tf) in tf.placeholder = "주소"}
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { (_) in
            
            let title = alert.textFields?[0].text
            let addr = alert.textFields?[1].text
            
            if self.departDAO.create(title: title!, addr: addr!) {
                self.departList = self.departDAO.find()
                self.tableView.reloadData()
                
                let navTitle = self.navigationItem.titleView as! UILabel
                navTitle.text = "부서 목록 \n" + "총 \(self.departList.count)개"
            }
            
        })
        
        self.present(alert, animated: false)
    }
    
}

extension DepartmentListVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.departList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = self.departList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DEPART_CELL")
        
        cell?.textLabel?.text = rowData.departTitle
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell?.detailTextLabel?.text = rowData.departAddr
        cell?.detailTextLabel?.font = .systemFont(ofSize: 12)
    
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        /// target of delete data
        let departCd = self.departList[indexPath.row].departCd
        
        // delete : DB와 data source
        if departDAO.remove(departCd: departCd) {
            self.departList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let departCd = self.departList[indexPath.row].departCd
        
        let infoVC = self.storyboard?.instantiateViewController(identifier: "DEPART_INFO")
        
        if let _infoVC = infoVC as? DepartmentInfoVC {
            _infoVC.departCd = departCd
            self.navigationController?.pushViewController(_infoVC, animated: true)
        }
    }
}
