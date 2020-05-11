
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
    
    deinit() {
        self.fmdb.close()
    }
    
}
