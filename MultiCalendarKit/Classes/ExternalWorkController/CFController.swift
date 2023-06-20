//
//  CFManager.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/09.
//

import RxSwift
import RxCocoa
import RxDataSources

@available(iOS 13, *)
public class CFController: NSObject {
    
    /**
        CalendarView 인스턴스 프로퍼티
     
        - Description:
            - CellType이 설정된 CalendarView 인스턴스가 할당된 프로퍼티. 해당 인스턴스를 실제 VC에서 등록하고 레이아웃 설정해서 사용하면 된다.
     */
    public let calendarView: CalendarView
    private let dataSourceManager: RxDataSourceManager
    private let sectionModelRelay: PublishRelay<[CalendarSectionModel]> = .init()
    
    let calendarType: CollectionCellManagerType
    let disposeBag: DisposeBag = .init()
    var collectionViewDataSource: RxCollectionViewSectionedReloadDataSource<CalendarSectionModel>?
    // 셀이 완전히 넘어가지 않았을 때, 데이터 값을 그대로 유지하기 위한 Row 값 저장 프로퍼티
    var moveCellRow: Int?
    var isAppearedView: Bool = false
    
    // MultiSelect일 때, 선택된 View 담기
    var selectedViews: [Int:[MultiSelectCellDayView]] = [:]
    
    /**
        CFManager 객체 생성 이니셜라이저
     
        - parameters:
            - with: Cell Type 지정을 위한 파라미터
            - viewWillAppear: 해당 매니저 객체를 활용 중인 ViewController의 willAppear Driver 객체 파라미터
            - beforeYear: 현재 년도로부터 몇 년 앞까지 설정 (미입력 시 1로 고정)
            - afterYear: 현재 년도로부터 몇 년 뒤까지 설정 (미입력 시 1로 고정)
     */
    public init(with calendarType: CollectionCellManagerType, viewWillAppear: Driver<Bool>, viewWillDisappear: Driver<Bool>, yearInterval: Int = 1) {
        self.calendarType = calendarType
        self.calendarView = .init(with: calendarType)
        self.dataSourceManager = .init(yearInterval: yearInterval)
        
        super.init()
        
        self.configureDataSource()
        self.configureBinding(with: viewWillAppear, viewWillDisappear: viewWillDisappear)
        self.configureActions()
    }
}

// MARK: 달력 스와이핑
extension CFController: UICollectionViewDelegate, UIScrollViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let dataSource = self.collectionViewDataSource, let model: CalendarSectionModel = dataSource.sectionModels.first else { return }
        
        self.calendarView.calendarCollectionView.visibleCells.forEach {
            guard let nowIndexPath = self.calendarView.calendarCollectionView.indexPath(for: $0) else { return }
            
            switch self.calendarType {
            case .inputType(_):
                break
                
            case .multiSelectType(let multipleManager):
                self.setSelectedViews(with: multipleManager, from: nowIndexPath.row)
            }
            
            if nowIndexPath.row == self.moveCellRow {
                let item: CellModel = model.items[nowIndexPath.row]

                switch item {
                case .inputCell(let inputCellDTO):
                    self.calendarView.yearMonthLabel.text = "\(inputCellDTO.year) \(inputCellDTO.month)"
                    
                case .multipleSelectCell(let multiSelectCellDTO):
                    self.calendarView.yearMonthLabel.text = "\(multiSelectCellDTO.year) \(multiSelectCellDTO.month)"
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard moveCellRow == nil, let dataSource = self.collectionViewDataSource, let model: CalendarSectionModel = dataSource.sectionModels.first else {
            self.moveCellRow = indexPath.row
            
            return
        }

        let item: CellModel = model.items[indexPath.row]

        switch item {
        case .inputCell(let inputCellDTO):
            self.calendarView.yearMonthLabel.text = "\(inputCellDTO.year) \(inputCellDTO.month)"
            
        case .multipleSelectCell(let multiSelectCellDTO):
            self.calendarView.yearMonthLabel.text = "\(multiSelectCellDTO.year) \(multiSelectCellDTO.month)"
        }
        
        self.moveCellRow = indexPath.row
    }
}

// MARK: 이니셜라이저에서 호출되는 기본 설정 요소들
private extension CFController {
    
    func configureDataSource() {
        self.collectionViewDataSource = .init(configureCell: { dataSource, collectionView, indexPath, item in
            switch self.calendarType {
            case .inputType:
                return self.createInputCell(with: collectionView, indexPath: indexPath, item: item)
                
            case .multiSelectType:
                return self.createMultipleCell(with: collectionView, indexPath: indexPath, item: item)
            }
        })
    }
    
    func configureBinding(with viewWillAppear: Driver<Bool>, viewWillDisappear: Driver<Bool>) {
        viewWillAppear.drive { [weak self] isAppear in
            // Tabbar와 같이 해당 드라이브의 값이 항상 false로 떨어질 수 있는 경우도 있음
            guard let self, (isAppear || !(self.isAppearedView)) else { return }
            
            switch self.calendarType {
            case .inputType(let inputManager):
                guard !(inputManager.isUpdated) else { break }
                
                // 이전 입력값들로 초기 구현 안 되어있으면 달력만 구현되도록 진행
                let section: CalendarSectionModel = self.dataSourceManager.fetchCalendarSectionModel(with: .input(nil))
                self.sectionModelRelay.accept([section])
                
            case .multiSelectType:
                let section: CalendarSectionModel = self.dataSourceManager.fetchCalendarSectionModel(with: .multiSelect)
                self.sectionModelRelay.accept([section])
            }
            
            self.isAppearedView = true
        }
        .disposed(by: disposeBag)
        
        viewWillDisappear.drive { [weak self] isDisappear in
            // Tabbar와 같이 해당 드라이브의 값이 항상 false로 떨어질 수 있는 경우도 있음
            guard let self, (isDisappear || self.isAppearedView) else { return }
            
            self.isAppearedView = false
        }
        .disposed(by: disposeBag)
        
        self.calendarView.calendarCollectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.bindSectionModelRelay()
        self.bindWithCellManager()
    }
}

// MARK: 버튼 액션
private extension CFController {
    
    func configureActions() {
        self.calendarView.prevButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .asDriver { _ in return .never() }
            .drive(with: self) { (owner, _) in
                guard let moveCellRow = owner.moveCellRow, moveCellRow > 0 else { return }
                
                let prevIndex: Int = moveCellRow - 1
                owner.moveCollectionCell(with: prevIndex, postion: .left)
            }
            .disposed(by: disposeBag)
        
        self.calendarView.nextButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .asDriver { _ in return .never() }
            .drive(with: self) { (owner, _) in
                guard let moveCellRow = owner.moveCellRow, let indexCount: Int = owner.fetchAllItemsCount(), moveCellRow < (indexCount - 2) else { return }
                
                let nextIndex: Int = moveCellRow + 1
                owner.moveCollectionCell(with: nextIndex, postion: .right)
            }
            .disposed(by: disposeBag)
    }
    
    func fetchAllItemsCount() -> Int? {
        guard let dataSource = self.collectionViewDataSource, let model: CalendarSectionModel = dataSource.sectionModels.first else { return nil }
        
        return model.items.count
    }
    
    func moveCollectionCell(with index: Int, postion: UICollectionView.ScrollPosition) {
        self.calendarView.calendarCollectionView.scrollToItem(at: .init(row: index, section: 0), at: postion, animated: true)
    }
}

// MARK: 바인딩 관련 로직
private extension CFController {
    
    func bindSectionModelRelay() {
        guard let collectionViewDataSource else { return }
        
        let modelRelayShared = sectionModelRelay.share()
        
        modelRelayShared
            .bind(to: self.calendarView.calendarCollectionView.rx.items(dataSource: collectionViewDataSource))
            .disposed(by: disposeBag)
        
        modelRelayShared
            .subscribe { event in
                guard let nowRow = self.dataSourceManager.fetchNowDayRow(), let sectionModel = event.element?.first, !(self.moveCellRow == nowRow), !(self.isAppearedView) else { return }
                
                let cellDTO: CellModel = sectionModel.items[nowRow]
                let indexPath: IndexPath = .init(row: nowRow, section: 0)
                self.moveCellRow = nowRow
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.calendarView.calendarCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
                    
                    switch cellDTO {
                    case .inputCell(let inputCellMonthDTO):
                        self.calendarView.yearMonthLabel.text = "\(inputCellMonthDTO.year) \(inputCellMonthDTO.month)"
                        
                    case .multipleSelectCell(let selectCellMonthDTO):
                        self.calendarView.yearMonthLabel.text = "\(selectCellMonthDTO.year) \(selectCellMonthDTO.month)"
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    func bindWithCellManager() {
        switch self.calendarType {
        case .inputType(let inputManager):
            inputManager.inputTextsRelay
                .asDriver { _ in return .never() }
                .drive(with: self) { (owner, texts) in
                    let sectionModel: CalendarSectionModel =  self.dataSourceManager.fetchCalendarSectionModel(with: .input(texts))
                    self.sectionModelRelay.accept([sectionModel])
                }
                .disposed(by: disposeBag)
            
        case .multiSelectType(let multipleManager):
            multipleManager.tappedCellDTORelay
                .asDriver { _ in return .never() }
                .drive(with: self) { (owner, _) in
                    owner.setSelectedViews(with: multipleManager)
                }
                .disposed(by: disposeBag)
        }
    }
}
