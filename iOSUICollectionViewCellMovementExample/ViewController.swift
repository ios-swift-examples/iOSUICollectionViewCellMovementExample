//
//  ViewController.swift
//  iOSUICollectionViewCellMovementExample
//
//  Created by 영준 이 on 2024/01/02.
//

import UIKit

struct Data{
    var index: Int
    var name: String
}

class DataCollectionViewCell: UICollectionViewCell {
    class Colors {
        static let background: [UIColor] = [.black, .blue, .brown, .cyan, .darkGray, .green, .lightGray, .magenta, .orange, .purple]
        static let foreground: [UIColor] = [.white, .white, .white, .black, .white, .black, .white, .white, .white, .white]
    }
    
    var data: Data? {
        didSet {
            updateData(data!)
        }
    }
    
    var nameLabel: UILabel = {
        var value: UILabel = .init()
        value.translatesAutoresizingMaskIntoConstraints = false
        
        return value
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupLayout()
    }
    
    func setupLayout() {
        self.addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        nameLabel.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor).isActive = true
        nameLabel.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor).isActive = true
        
        let layer = self.layer
        layer.cornerRadius = 16
        layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData(_ data: Data)  {
        nameLabel.text = data.name
        backgroundColor = Colors.background[data.index % Colors.background.count]
        nameLabel.textColor = Colors.foreground[data.index % Colors.foreground.count]
    }
}

class MainViewController: UIViewController {
    class Cells {
        static let `default` = "DataCell"
    }
    
    var datas = (0..<10).map{ Data.init(index: $0, name: "Data \($0 + 1)") }
    
    var collectionView: UICollectionView = {
        var value: UICollectionView = .init(frame: .init(origin: .zero, size: .init(width: 500, height: 500)), collectionViewLayout: UICollectionViewFlowLayout())
        value.translatesAutoresizingMaskIntoConstraints = false
        value.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        return value
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setupLayout()
        self.setupCells()
        self.setupData()
        self.setupGesture()
    }
    
    func setupCells() {
        collectionView.register(DataCollectionViewCell.self, forCellWithReuseIdentifier: Cells.default)
    }

    func setupLayout() {
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func setupData(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupGesture(){
        let longPress : UILongPressGestureRecognizer = .init(target: self, action: #selector(onLongPressed))
        collectionView.addGestureRecognizer(longPress)
    }
    
    var movingCell: UICollectionViewCell!
    var originalCellPos: CGPoint = .zero
    
    func cellFor(indexPath: IndexPath) -> UICollectionViewCell? {
        return collectionView.cellForItem(at: indexPath)
    }
    
    func finishMovingCell() {
        movingCell?.alpha = 1
        movingCell = nil
    }
    
    @objc func onLongPressed(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state){
            case .began:
                let pos = gesture.location(in: self.collectionView);
                guard let indexPath = collectionView.indexPathForItem(at: pos) else{
                    return;
                }
                collectionView.beginInteractiveMovementForItem(at: indexPath);
                
                guard let cell = cellFor(indexPath: indexPath) as? DataCollectionViewCell, let data = cell.data else {
                    return
                }
            
                debugPrint("Long Press began. cellData[\(data.name)] data[\(datas[indexPath.item].name)]")
        
                
                cell.alpha = 0.5
                movingCell = cell
                break
            case .changed:
//                debugPrint("Long Press moving")
                let pos = gesture.location(in: self.collectionView);

                let index = self.collectionView.indexPathForItem(at: pos);
                self.collectionView.updateInteractiveMovementTargetPosition(pos);
                guard index != nil else{
                    return;
                }
                break
            case .ended:
                self.collectionView.endInteractiveMovement();
                finishMovingCell()
                break
        @unknown default:
                self.collectionView.cancelInteractiveMovement()
                finishMovingCell()
                break
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.default, for: indexPath) as! DataCollectionViewCell
        cell.data = datas[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item != 2
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        let sourceIndex = sourceIndexPath.row;
        let destIndex = destinationIndexPath.row;
        let source = datas[sourceIndex]
        
        if (sourceIndex < destIndex) {
            datas.insert(source, at: destIndex)
            datas.remove(at: sourceIndex)
        }else {
            datas.remove(at: sourceIndex)
            datas.insert(source, at: destIndex)
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 88, height: 88)
    }
}
