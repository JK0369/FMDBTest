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
    
    // 모든 부서 정보 탐색
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
    
    /// 단일 부서 정보를 읽어오는 함수
    func get(departCd: Int) -> DepartRecord? {
        let sql = """
                    SELECT depart_cd, depart_title, depart_addr
                    FROM department
                    WHERE depart_cd = ?
                """
        
        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [departCd])
        
        if let _rs = rs { // 반환됐던 결과집합은 옵셔널타입
            _rs.next()
            
            let departId = _rs.int(forColumn: "depart_cd")
            let departTitle = _rs.string(forColumn: "depart_title")
            let departAddr = _rs.string(forColumn: "depart_addr")
            
            return (Int(departId), departTitle!, departAddr!)
        } else {
            return nil
        }
    }
    
    func create(title: String!, addr: String!) -> Bool {
        do {
            let sql = """
                        INSERT INTO department (depart_title, depart_addr)
                        VALUES(?, ?)
                    """
            
            // 내용을 변경하므로 executeQuery 대신에 executeUpdate사용
            try self.fmdb.executeUpdate(sql, values: [title!, addr!])
            return true
        } catch let error as NSError {
            print("Insert Error : \(error.localizedDescription)")
            return false
        }
    }
    
    func remove(departCd: Int) -> Bool {
        do {
            let sql = "DELETE FROM department WHERE depat_cd = ?"
            try self.fmdb.executeUpdate(sql, values: [departCd])
            return true
        } catch let error as NSError {
            print("DELETE Error : \(error.localizedDescription)")
            retur false
        }
    }
}
