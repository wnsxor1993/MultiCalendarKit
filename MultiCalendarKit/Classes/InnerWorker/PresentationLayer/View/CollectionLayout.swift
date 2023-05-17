//
//  CollectionLayout.swift
//  CalendarFramework
//
//  Created by Zeto on 2023/01/06.
//

import UIKit

enum CollectionLayout {
    
    case calendarLayout
}

extension CollectionLayout {
    
    var compositionalLayoutSection: UICollectionViewCompositionalLayout? {
        switch self {
        case .calendarLayout:
            guard let collectionLayout = self.createCalendarLayout() else { return nil }
            
            return UICollectionViewCompositionalLayout(section: collectionLayout)
        }
    }
}

private extension CollectionLayout {
    
    func createCalendarLayout() -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
}
