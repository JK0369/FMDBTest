
// 열거형으로 상태 정의
enum EmpStateType: Int {
    case ING = 0, STOP, OUT /// 재직중(0), 휴직(1), 퇴사(2)
    
    // 재직 상태 상수를 문자열로 변환해 주는 메소드
    func desc() -> String {
        switch self {
        case .ING: return "재직중"
        case .STOP: return "휴직"
        case .OUT: return "퇴사"
        }
    }
    
}

// VO구조체
/// VO객체는 struct를 사용할 것 : class보다 struct가 객체의 생성 및 초기화 과정이 훨씬 가볍고 신속
struct EmployeeVO {
    var empCd = 0
    var empName = ""
    var joinDate = ""
    var stateCd = EmpStateType.ING
    var departCd = 0
    var departTitle = ""
}

class EmployeeDAO {
    
    lazy var fmdb: FMDatabase! = {
        let fileMgr = FileManager.default
        let docPath = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first
        let dbPath = docPath!.appendingPathComponent("hr.sqlite").path
        
        if fileMgr.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "hr", ofType: "sqlite")
            try! fileMgr.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        
        let db = FMDatabase(path: dbPath)
        return db
    }()
    
    init() {
        self.fmdb.open()
    }
    
    deinit {
        self.fmdb.close()
    }
    
    func find(departCd: Int = 0) -> [EmployeeVO] {
      // 반환할 데이터를 담을 [DepartRecord] 타입의 객체 정의
      var employeeList = [EmployeeVO]()
      
      do {
        // 1. 조건절 정의
        let condition = departCd == 0 ? "" : "WHERE Employee.depart_cd = \(departCd)"
        
        let sql = """
          SELECT emp_cd, emp_name, join_date, state_cd,
                 department.depart_title
          FROM employee
          JOIN department On department.depart_cd = employee.depart_cd
          \(condition)
          ORDER BY employee.depart_cd ASC
        """
        
        let rs = try self.fmdb.executeQuery(sql, values: nil)
        while rs.next() {
          var record = EmployeeVO()
          record.empCd = Int(rs.int(forColumn: "emp_cd"))
          record.empName = rs.string(forColumn: "emp_name")!
          record.joinDate = rs.string(forColumn: "join_date")!
          record.departTitle = rs.string(forColumn: "depart_title")!
          
          let cd = Int(rs.int(forColumn: "state_cd")) // DB에서 읽어온 state_cd 값
          record.stateCd = EmpStateType(rawValue: cd)!
          
          employeeList.append(record)
        }
      } catch let error as NSError {
        print("find failed: \(error.localizedDescription)")
      }
      return employeeList
    }
    
    func get(empCd: Int) -> EmployeeVO? {
        let sql = """
                    SELECT emp_cd, emp_name, join_date, state_cd,
                            department.depart_title
                    FROM employee
                    JOIN department ON department.depart_cd = employee.depart_cd
                    WHERE emp_cd = ?
                    """
        
        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [empCd])
        guard let _rs = rs else {return nil}
        
        _rs.next()
        
        var record = EmployeeVO()
        record.empCd = Int(_rs.int(forColumn: "emp_cd"))
        record.empName = _rs.string(forColumn: "emp_name")!
        record.joinDate = _rs.string(forColumn: "join_date")!
        record.departTitle = _rs.string(forColumn: "depart_title")!
        
        let cd = Int(_rs.int(forColumn: "state_cd"))
        record.stateCd = EmpStateType(rawValue: cd)!
        
        return record
    }
    
    func create(param: EmployeeVO) -> Bool {
        do {
            let sql = """
                        INSERT INTO employee (emp_name, join_date, state_cd, depart_cd)
                        VALUES (?, ?, ?, ?)
            """
            
            var params = [Any]()
            params.append(param.empName)
            params.append(param.joinDate)
            params.append(param.stateCd.rawValue)
            params.append(param.departCd)
            
            try self.fmdb.executeUpdate(sql, values: params)
            
            return true
        } catch let error as NSError {
            print("Insert Error : \(error.localizedDescription)")
            return false
        }
    }
    
    func remove(empCd: Int) -> Bool {
        do {
            let sql = "DELETE FROM employee WHERE emp_cd = ?"
            try self.fmdb.executeUpdate(sql, values: [empCd])
            return true
        } catch let error as NSError {
            print("Delete Error : \(error.localizedDescription)")
            return false
        }
    }
    
    func editState(empCd: Int, stateCd: EmpStateType) -> Bool {
        do {
            let sql = "UPDATE employee SET state_cd = ? WHERE emp_cd = ?"
            var params = [Any]()
            params.append(stateCd.rawValue)
            params.append(empCd)
            
            try self.fmdb.executeUpdate(sql, values: params)
            return true
        } catch let error as NSError {
            print("UPDATE Error : \(error.localizedDescription)")
            return false
        }
    }
    
}
