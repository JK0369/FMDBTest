//
//  DepartmentInfoVC.swift
//  FMDBTest
//
//  Created by 김종권 on 2020/05/11.
//  Copyright © 2020 imustang. All rights reserved.
//

import UIKit
class DepartmentInfoVC: UITableViewController {
    typealias DepartRecord = (departCd: Int, departTitle: String, departAddr: String)
    
    var departCd: Int!
    
    let departDAO = DepartmentDAO()
    let empDAO = EmployeeDAO()
    
    var departInfo: DepartRecord!
    var empList: [EmployeeVO]!
    
    override func viewDidLoad() {
        self.departInfo = self.departDAO.get(departCd: self.departCd)
        self.empList = self.empDAO.find(departCd: self.departCd)
        self.navigationItem.title = "\(self.departInfo.departTitle)"
    }
}

extension DepartmentInfoVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // 헤더에 들어갈 레이블 객체
        let textHeder = UILabel(frame: CGRect(x: 35, y: 5, width: 200, height: 30))
        textHeder.font = .systemFont(ofSize: 15, weight: UIFont.Weight(rawValue: 2.5))
        textHeder.textColor = UIColor(red: 0.03, green: 0.28, blue: 0.71, alpha: 1.0)
        
        // 헤더에 들어갈 이미지 뷰
        let icon = UIImageView()
        icon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        
        // 섹션에 따라 타이틀과 이미지 다르게 설정
        if section == 0 {
            textHeder.text = "부서 정보"
            icon.image = UIImage(imageLiteralResourceName: "depart")
        } else {
            textHeder.text = "소속 사원"
            icon.image = UIImage(imageLiteralResourceName: "employee")
        }
        
        // 레이블과 뷰를 담을 컨테이너용 뷰 객체 정의
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        v.backgroundColor = UIColor(red: 0.93, green: 0.96, blue: 0.99, alpha: 1.0)
        
        // 뷰에 레이블과 뷰 추가
        v.addSubview(textHeder)
        v.addSubview(icon)
        
        return v
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return self.empList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DEPART_CELL")
            
            cell?.textLabel?.font = .systemFont(ofSize: 13)
            cell?.detailTextLabel?.font = .systemFont(ofSize: 12)
            
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = "부서 코드"
                cell?.detailTextLabel?.text = "\(self.departInfo.departCd)"
            case 1:
                cell?.textLabel?.text = "부서명"
                cell?.detailTextLabel?.text = self.departInfo.departTitle
            case 2:
                cell?.textLabel?.text = "부서 주소"
                cell?.detailTextLabel?.text = self.departInfo.departAddr
            default:
                ()
            }
            return cell!
        } else { /// indexPath.section == 1
            let row = self.empList[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EMP_CELL")
            cell?.textLabel?.text = "\(row.empName) (입사일: \(row.joinDate))"
            cell?.textLabel?.font = .systemFont(ofSize: 12)
            
            let state = UISegmentedControl(items: ["재직중", "휴직", "퇴사"])
            state.frame.origin.x = self.view.frame.width - state.frame.width - 10
            state.frame.origin.y = 10
            state.selectedSegmentIndex = row.stateCd.rawValue
            
            cell?.contentView.addSubview(state)
            return cell!
        }

    }
}
