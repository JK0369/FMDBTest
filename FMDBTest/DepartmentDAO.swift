//
//  DepartmentDAO.swift
//  FMDBTest
//
//  Created by 김종권 on 2020/05/10.
//  Copyright © 2020 imustang. All rights reserved.
//

import UIKit

// DepartmentDAO.swift
class DepartmentDAO {
    
    /// 연관성 있는 데이터 : 튜플이 가장 적합
    /// 딕셔너리는 데이터타입이 너무 다양하고, VO패턴의 객체는 번거로움
    typealias DepartRecord = (Int, String, String)
    
    /// SQLite connection
    lazy var fmdb : FMDatabase! = {
        /// 1. 파일 매니저 객체를 생성 및 DB경로 획득
        let fileMgr = FileManager.default
        
        let docPath = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first
        let dbPath = docPath!.appendingPathComponent("hr.sqlite").path
        
        /// 2. 샌드박스 내에 파일이 없다면 미리 만들어 둔 DB (hr.sqlite)를 가져와 복사
        if fileMgr.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "hr", ofType: "sqlite")
            try! fileMgr.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        
        /// 3. DB객체 생성
        let db = FMDatabase(path: dbPath)
        return db
    }()
    
    init() {
        self.fmdb.open()
    }
    
    deinit {
        self.fmdb.close()
    }
    
    func find() -> [DepartRecord] {
        var departList = [DepartRecord]()
        
        do {
            /// 1) sql
            let sql = """
                        SELECT depart_cd, depart_title, depart_addr
                        FROM department
                        ORDER BY depart_cd ASC
                    """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            /// 2) ResultSet
            while rs.next() {
                let departCd = rs.int(forColumn: "depart_cd")
                let departTitle = rs.string(forColumn: "depart_title")
                let departAddr = rs.string(forColumn: "depart_addr")
                
                // 3) 힙 영역에 할당된 변수에 append
                departList.append((Int(departCd), departTitle!, departAddr!))
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        return departList
    }
}
