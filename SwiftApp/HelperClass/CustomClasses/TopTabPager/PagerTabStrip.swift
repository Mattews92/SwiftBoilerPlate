
//  ButtonBarPagerTabStripViewController.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2017 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit

public enum ButtonBarItemSpec<CellType: UICollectionViewCell> {
    
    case nibFile(nibName: String, bundle: Bundle?, width:((IndicatorInfo)-> CGFloat))
    case cellClass(width:((IndicatorInfo)-> CGFloat))
    
    public var weight: ((IndicatorInfo) -> CGFloat) {
        switch self {
        case .cellClass(let widthCallback):
            return widthCallback
        case .nibFile(_, _, let widthCallback):
            return widthCallback
        }
    }
}

public struct ButtonBarPagerTabStripSettings {
    
    public struct Style {
        public var buttonBarBackgroundColor: UIColor?
        public var buttonBarMinimumInteritemSpacing: CGFloat?
        public var buttonBarMinimumLineSpacing: CGFloat?
        public var buttonBarLeftContentInset: CGFloat?
        public var buttonBarRightContentInset: CGFloat?
        
        public var selectedBarBackgroundColor = UIColor.black
        public var selectedBarHeight: CGFloat = 5
        public var selectedBarVerticalAlignment: SelectedBarVerticalAlignment = .bottom
        
        public var buttonBarItemBackgroundColor: UIColor?
        public var buttonBarItemFont = UIFont.systemFont(ofSize: 18)
        public var buttonBarItemLeftRightMargin: CGFloat = 8
        public var buttonBarItemTitleColor: UIColor?
        @available(*, deprecated: 7.0.0) public var buttonBarItemsShouldFillAvailiableWidth: Bool {
            set {
                buttonBarItemsShouldFillAvailableWidth = newValue
            }
            get {
                return buttonBarItemsShouldFillAvailableWidth
            }
        }
        public var buttonBarItemsShouldFillAvailableWidth = true
        // only used if button bar is created programaticaly and not using storyboards or nib files
        public var buttonBarHeight: CGFloat?
    }
    
    public var style = Style()
}

open class ButtonBarPagerTabStripViewController: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripIsProgressiveDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public var settings = ButtonBarPagerTabStripSettings()
    
    public var buttonBarItemSpec: ButtonBarItemSpec<ButtonBarViewCell>!
    
    public var changeCurrentIndex: ((_ oldCell: ButtonBarViewCell?, _ newCell: ButtonBarViewCell?, _ animated: Bool) -> Void)?
    public var changeCurrentIndexProgressive: ((_ oldCell: ButtonBarViewCell?, _ newCell: ButtonBarViewCell?, _ progressPercentage: CGFloat, _ changeCurrentIndex: Bool, _ animated: Bool) -> Void)?
    
    @IBOutlet public weak var buttonBarView: ButtonBarView!
    
    lazy private var cachedCellWidths: [CGFloat]? = { [unowned self] in
        return self.calculateWidths()
        }()
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
        datasource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        datasource = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        buttonBarItemSpec = .nibFile(nibName: "ButtonCell", bundle: Bundle(for: ButtonBarViewCell.self), width: { [weak self] (childItemInfo) -> CGFloat in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = self?.settings.style.buttonBarItemFont
            label.text = childItemInfo.title
            let labelSize = label.intrinsicContentSize
            return labelSize.width + (self?.settings.style.buttonBarItemLeftRightMargin ?? 8) * 2
        })
        
        let buttonBarViewAux = buttonBarView ?? {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            let buttonBarHeight = settings.style.buttonBarHeight ?? 44
            let buttonBar = ButtonBarView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: buttonBarHeight), collectionViewLayout: flowLayout)
            buttonBar.backgroundColor = .orange
            buttonBar.selectedBar.backgroundColor = .black
            buttonBar.autoresizingMask = .flexibleWidth
            var newContainerViewFrame = containerView.frame
            newContainerViewFrame.origin.y = buttonBarHeight
            newContainerViewFrame.size.height = containerView.frame.size.height - (buttonBarHeight - containerView.frame.origin.y)
            containerView.frame = newContainerViewFrame
            return buttonBar
            }()
        buttonBarView = buttonBarViewAux
        
        if buttonBarView.superview == nil {
            view.addSubview(buttonBarView)
        }
        if buttonBarView.delegate == nil {
            buttonBarView.delegate = self
        }
        if buttonBarView.dataSource == nil {
            buttonBarView.dataSource = self
        }
        buttonBarView.scrollsToTop = false
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = settings.style.buttonBarMinimumInteritemSpacing ?? flowLayout.minimumInteritemSpacing
        flowLayout.minimumLineSpacing = settings.style.buttonBarMinimumLineSpacing ?? flowLayout.minimumLineSpacing
        let sectionInset = flowLayout.sectionInset
        flowLayout.sectionInset = UIEdgeInsets(top: sectionInset.top, left: settings.style.buttonBarLeftContentInset ?? sectionInset.left, bottom: sectionInset.bottom, right: settings.style.buttonBarRightContentInset ?? sectionInset.right)
        
        buttonBarView.showsHorizontalScrollIndicator = false
        buttonBarView.backgroundColor = settings.style.buttonBarBackgroundColor ?? buttonBarView.backgroundColor
        buttonBarView.selectedBar.backgroundColor = settings.style.selectedBarBackgroundColor
        
        buttonBarView.selectedBarHeight = settings.style.selectedBarHeight
        buttonBarView.selectedBarVerticalAlignment = settings.style.selectedBarVerticalAlignment
        
        // register button bar item cell
        switch buttonBarItemSpec! {
        case .nibFile(let nibName, let bundle, _):
            buttonBarView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier:"Cell")
        case .cellClass:
            buttonBarView.register(ButtonBarViewCell.self, forCellWithReuseIdentifier:"Cell")
        }
        //-
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonBarView.layoutIfNeeded()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard isViewAppearing || isViewRotating else { return }
        
        // Force the UICollectionViewFlowLayout to get laid out again with the new size if
        // a) The view is appearing.  This ensures that
        //    collectionView:layout:sizeForItemAtIndexPath: is called for a second time
        //    when the view is shown and when the view *frame(s)* are actually set
        //    (we need the view frame's to have been set to work out the size's and on the
        //    first call to collectionView:layout:sizeForItemAtIndexPath: the view frame(s)
        //    aren't set correctly)
        // b) The view is rotating.  This ensures that
        //    collectionView:layout:sizeForItemAtIndexPath: is called again and can use the views
        //    *new* frame so that the buttonBarView cell's actually get resized correctly
        cachedCellWidths = calculateWidths()
        buttonBarView.collectionViewLayout.invalidateLayout()
        // When the view first appears or is rotated we also need to ensure that the barButtonView's
        // selectedBar is resized and its contentOffset/scroll is set correctly (the selected
        // tab/cell may end up either skewed or off screen after a rotation otherwise)
        buttonBarView.moveTo(index: currentIndex, animated: false, swipeDirection: .none, pagerScroll: .scrollOnlyIfOutOfScreen)
    }
    
    // MARK: - Public Methods
    
    open override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        guard isViewLoaded else { return }
        buttonBarView.reloadData()
        cachedCellWidths = calculateWidths()
        buttonBarView.moveTo(index: currentIndex, animated: false, swipeDirection: .none, pagerScroll: .yes)
    }
    
    open func calculateStretchedCellWidths(_ minimumCellWidths: [CGFloat], suggestedStretchedCellWidth: CGFloat, previousNumberOfLargeCells: Int) -> CGFloat {
        var numberOfLargeCells = 0
        var totalWidthOfLargeCells: CGFloat = 0
        
        for minimumCellWidthValue in minimumCellWidths where minimumCellWidthValue > suggestedStretchedCellWidth {
            totalWidthOfLargeCells += minimumCellWidthValue
            numberOfLargeCells += 1
        }
        
        guard numberOfLargeCells > previousNumberOfLargeCells else { return suggestedStretchedCellWidth }
        
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        let collectionViewAvailiableWidth = buttonBarView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        let numberOfCells = minimumCellWidths.count
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumLineSpacing
        
        let numberOfSmallCells = numberOfCells - numberOfLargeCells
        let newSuggestedStretchedCellWidth = (collectionViewAvailiableWidth - totalWidthOfLargeCells - cellSpacingTotal) / CGFloat(numberOfSmallCells)
        
        return calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: newSuggestedStretchedCellWidth, previousNumberOfLargeCells: numberOfLargeCells)
    }
    
    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
        guard shouldUpdateButtonBarView else { return }
        buttonBarView.moveTo(index: toIndex, animated: false, swipeDirection: toIndex < fromIndex ? .right : .left, pagerScroll: .yes)
        
        if let changeCurrentIndex = changeCurrentIndex {
            let oldIndexPath = IndexPath(item: currentIndex != fromIndex ? fromIndex : toIndex, section: 0)
            let newIndexPath = IndexPath(item: currentIndex, section: 0)
            
            let cells = cellForItems(at: [oldIndexPath, newIndexPath], reloadIfNotVisible: collectionViewDidLoad)
            changeCurrentIndex(cells.first!, cells.last!, true)
        }
    }
    
    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        guard shouldUpdateButtonBarView else { return }
        buttonBarView.move(fromIndex: fromIndex, toIndex: toIndex, progressPercentage: progressPercentage, pagerScroll: .yes)
        if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
            let oldIndexPath = IndexPath(item: currentIndex != fromIndex ? fromIndex : toIndex, section: 0)
            let newIndexPath = IndexPath(item: currentIndex, section: 0)
            
            let cells = cellForItems(at: [oldIndexPath, newIndexPath], reloadIfNotVisible: collectionViewDidLoad)
            changeCurrentIndexProgressive(cells.first!, cells.last!, progressPercentage, indexWasChanged, true)
        }
    }
    
    private func cellForItems(at indexPaths: [IndexPath], reloadIfNotVisible reload: Bool = true) -> [ButtonBarViewCell?] {
        let cells = indexPaths.map { buttonBarView.cellForItem(at: $0) as? ButtonBarViewCell }
        
        if reload {
            let indexPathsToReload = cells.enumerated()
                .flatMap { (arg) -> IndexPath? in
                    let (index, cell) = arg
                    return cell == nil ? indexPaths[index] : nil
                }
                .flatMap { (indexPath: IndexPath) -> IndexPath? in
                    return (indexPath.item >= 0 && indexPath.item < buttonBarView.numberOfItems(inSection: indexPath.section)) ? indexPath : nil
            }
            
            if !indexPathsToReload.isEmpty {
                buttonBarView.reloadItems(at: indexPathsToReload)
            }
        }
        
        return cells
    }
    
    // MARK: - UICollectionViewDelegateFlowLayut
    
    @objc open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellWidthValue = cachedCellWidths?[indexPath.row] else {
            fatalError("cachedCellWidths for \(indexPath.row) must not be nil")
        }
        return CGSize(width: cellWidthValue, height: collectionView.frame.size.height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != currentIndex else { return }
        
        buttonBarView.moveTo(index: indexPath.item, animated: true, swipeDirection: .none, pagerScroll: .yes)
        shouldUpdateButtonBarView = false
        
        let oldIndexPath = IndexPath(item: currentIndex, section: 0)
        let newIndexPath = IndexPath(item: indexPath.item, section: 0)
        
        let cells = cellForItems(at: [oldIndexPath, newIndexPath], reloadIfNotVisible: collectionViewDidLoad)
        
        if pagerBehaviour.isProgressiveIndicator {
            if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(cells.first!, cells.last!, 1, true, true)
            }
        } else {
            if let changeCurrentIndex = changeCurrentIndex {
                changeCurrentIndex(cells.first!, cells.last!, true)
            }
        }
        moveToViewController(at: indexPath.item)
    }
    
    // MARK: - UICollectionViewDataSource
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ButtonBarViewCell else {
            fatalError("UICollectionViewCell should be or extend from ButtonBarViewCell")
        }
        
        collectionViewDidLoad = true
        
        let childController = viewControllers[indexPath.item] as! IndicatorInfoProvider // swiftlint:disable:this force_cast
        let indicatorInfo = childController.indicatorInfo(for: self)
        
        cell.label.text = indicatorInfo.title
        cell.label.font = settings.style.buttonBarItemFont
        cell.label.textColor = settings.style.buttonBarItemTitleColor ?? cell.label.textColor
        cell.contentView.backgroundColor = settings.style.buttonBarItemBackgroundColor ?? cell.contentView.backgroundColor
        cell.backgroundColor = settings.style.buttonBarItemBackgroundColor ?? cell.backgroundColor
        if let image = indicatorInfo.image {
            cell.imageView.image = image
        }
        if let highlightedImage = indicatorInfo.highlightedImage {
            cell.imageView.highlightedImage = highlightedImage
        }
        
        configureCell(cell, indicatorInfo: indicatorInfo)
        
        if pagerBehaviour.isProgressiveIndicator {
            if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(currentIndex == indexPath.item ? nil : cell, currentIndex == indexPath.item ? cell : nil, 1, true, false)
            }
        } else {
            if let changeCurrentIndex = changeCurrentIndex {
                changeCurrentIndex(currentIndex == indexPath.item ? nil : cell, currentIndex == indexPath.item ? cell : nil, false)
            }
        }
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    
    open override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        
        guard scrollView == containerView else { return }
        shouldUpdateButtonBarView = true
    }
    
    open func configureCell(_ cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo) {
    }
    
    private func calculateWidths() -> [CGFloat] {
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        let numberOfCells = viewControllers.count
        
        var minimumCellWidths = [CGFloat]()
        var collectionViewContentWidth: CGFloat = 0
        
        for viewController in viewControllers {
            let childController = viewController as! IndicatorInfoProvider // swiftlint:disable:this force_cast
            let indicatorInfo = childController.indicatorInfo(for: self)
            switch buttonBarItemSpec! {
            case .cellClass(let widthCallback):
                let width = widthCallback(indicatorInfo)
                minimumCellWidths.append(width)
                collectionViewContentWidth += width
            case .nibFile(_, _, let widthCallback):
                let width = widthCallback(indicatorInfo)
                minimumCellWidths.append(width)
                collectionViewContentWidth += width
            }
        }
        
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumLineSpacing
        collectionViewContentWidth += cellSpacingTotal
        
        let collectionViewAvailableVisibleWidth = buttonBarView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        
        if !settings.style.buttonBarItemsShouldFillAvailableWidth || collectionViewAvailableVisibleWidth < collectionViewContentWidth {
            return minimumCellWidths
        } else {
            let stretchedCellWidthIfAllEqual = (collectionViewAvailableVisibleWidth - cellSpacingTotal) / CGFloat(numberOfCells)
            let generalMinimumCellWidth = calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: stretchedCellWidthIfAllEqual, previousNumberOfLargeCells: 0)
            var stretchedCellWidths = [CGFloat]()
            
            for minimumCellWidthValue in minimumCellWidths {
                let cellWidth = (minimumCellWidthValue > generalMinimumCellWidth) ? minimumCellWidthValue : generalMinimumCellWidth
                stretchedCellWidths.append(cellWidth)
            }
            
            return stretchedCellWidths
        }
    }
    
    private var shouldUpdateButtonBarView = true
    private var collectionViewDidLoad = false
    
}


public struct IndicatorInfo {
    
    public var title: String?
    public var image: UIImage?
    public var highlightedImage: UIImage?
    
    public init(title: String?) {
        self.title = title
    }
    
    public init(image: UIImage?, highlightedImage: UIImage? = nil) {
        self.image = image
        self.highlightedImage = highlightedImage
    }
    
    public init(title: String?, image: UIImage?, highlightedImage: UIImage? = nil) {
        self.title = title
        self.image = image
        self.highlightedImage = highlightedImage
    }
    
}

extension IndicatorInfo : ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        title = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        title = value
    }
    
    public init(unicodeScalarLiteral value: String) {
        title = value
    }
}


public enum PagerScroll {
    case no
    case yes
    case scrollOnlyIfOutOfScreen
}

public enum SelectedBarAlignment {
    case left
    case center
    case right
    case progressive
}

public enum SelectedBarVerticalAlignment {
    case top
    case middle
    case bottom
}

open class ButtonBarView: UICollectionView {
    
    open lazy var selectedBar: UIView = { [unowned self] in
        let bar  = UIView(frame: CGRect(x: 0, y: self.frame.size.height - CGFloat(self.selectedBarHeight), width: 0, height: CGFloat(self.selectedBarHeight)))
        bar.layer.zPosition = 9999
        return bar
        }()
    
    internal var selectedBarHeight: CGFloat = 4 {
        didSet {
            updateSelectedBarYPosition()
        }
    }
    var selectedBarVerticalAlignment: SelectedBarVerticalAlignment = .bottom
    var selectedBarAlignment: SelectedBarAlignment = .center
    var selectedIndex = 0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(selectedBar)
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        addSubview(selectedBar)
    }
    
    open func moveTo(index: Int, animated: Bool, swipeDirection: SwipeDirection, pagerScroll: PagerScroll) {
        selectedIndex = index
        updateSelectedBarPosition(animated, swipeDirection: swipeDirection, pagerScroll: pagerScroll)
    }
    
    open func move(fromIndex: Int, toIndex: Int, progressPercentage: CGFloat, pagerScroll: PagerScroll) {
        selectedIndex = progressPercentage > 0.5 ? toIndex : fromIndex
        
        let fromFrame = layoutAttributesForItem(at: IndexPath(item: fromIndex, section: 0))!.frame
        let numberOfItems = dataSource!.collectionView(self, numberOfItemsInSection: 0)
        
        var toFrame: CGRect
        
        if toIndex < 0 || toIndex > numberOfItems - 1 {
            if toIndex < 0 {
                let cellAtts = layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
                toFrame = cellAtts!.frame.offsetBy(dx: -cellAtts!.frame.size.width, dy: 0)
            } else {
                let cellAtts = layoutAttributesForItem(at: IndexPath(item: (numberOfItems - 1), section: 0))
                toFrame = cellAtts!.frame.offsetBy(dx: cellAtts!.frame.size.width, dy: 0)
            }
        } else {
            toFrame = layoutAttributesForItem(at: IndexPath(item: toIndex, section: 0))!.frame
        }
        
        var targetFrame = fromFrame
        targetFrame.size.height = selectedBar.frame.size.height
        targetFrame.size.width += (toFrame.size.width - fromFrame.size.width) * progressPercentage
        targetFrame.origin.x += (toFrame.origin.x - fromFrame.origin.x) * progressPercentage
        
        selectedBar.frame = CGRect(x: targetFrame.origin.x, y: selectedBar.frame.origin.y, width: targetFrame.size.width, height: selectedBar.frame.size.height)
        
        var targetContentOffset: CGFloat = 0.0
        if contentSize.width > frame.size.width {
            let toContentOffset = contentOffsetForCell(withFrame: toFrame, andIndex: toIndex)
            let fromContentOffset = contentOffsetForCell(withFrame: fromFrame, andIndex: fromIndex)
            
            targetContentOffset = fromContentOffset + ((toContentOffset - fromContentOffset) * progressPercentage)
        }
        
        setContentOffset(CGPoint(x: targetContentOffset, y: 0), animated: false)
    }
    
    open func updateSelectedBarPosition(_ animated: Bool, swipeDirection: SwipeDirection, pagerScroll: PagerScroll) {
        var selectedBarFrame = selectedBar.frame
        
        let selectedCellIndexPath = IndexPath(item: selectedIndex, section: 0)
        let attributes = layoutAttributesForItem(at: selectedCellIndexPath)
        let selectedCellFrame = attributes!.frame
        
        updateContentOffset(animated: animated, pagerScroll: pagerScroll, toFrame: selectedCellFrame, toIndex: (selectedCellIndexPath as NSIndexPath).row)
        
        selectedBarFrame.size.width = selectedCellFrame.size.width
        selectedBarFrame.origin.x = selectedCellFrame.origin.x
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.selectedBar.frame = selectedBarFrame
            })
        } else {
            selectedBar.frame = selectedBarFrame
        }
    }
    
    // MARK: - Helpers
    
    private func updateContentOffset(animated: Bool, pagerScroll: PagerScroll, toFrame: CGRect, toIndex: Int) {
        guard pagerScroll != .no || (pagerScroll != .scrollOnlyIfOutOfScreen && (toFrame.origin.x < contentOffset.x || toFrame.origin.x >= (contentOffset.x + frame.size.width - contentInset.left))) else { return }
        let targetContentOffset = contentSize.width > frame.size.width ? contentOffsetForCell(withFrame: toFrame, andIndex: toIndex) : 0
        setContentOffset(CGPoint(x: targetContentOffset, y: 0), animated: animated)
    }
    
    private func contentOffsetForCell(withFrame cellFrame: CGRect, andIndex index: Int) -> CGFloat {
        let sectionInset = (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset // swiftlint:disable:this force_cast
        var alignmentOffset: CGFloat = 0.0
        
        switch selectedBarAlignment {
        case .left:
            alignmentOffset = sectionInset.left
        case .right:
            alignmentOffset = frame.size.width - sectionInset.right - cellFrame.size.width
        case .center:
            alignmentOffset = (frame.size.width - cellFrame.size.width) * 0.5
        case .progressive:
            let cellHalfWidth = cellFrame.size.width * 0.5
            let leftAlignmentOffset = sectionInset.left + cellHalfWidth
            let rightAlignmentOffset = frame.size.width - sectionInset.right - cellHalfWidth
            let numberOfItems = dataSource!.collectionView(self, numberOfItemsInSection: 0)
            let progress = index / (numberOfItems - 1)
            alignmentOffset = leftAlignmentOffset + (rightAlignmentOffset - leftAlignmentOffset) * CGFloat(progress) - cellHalfWidth
        }
        
        var contentOffset = cellFrame.origin.x - alignmentOffset
        contentOffset = max(0, contentOffset)
        contentOffset = min(contentSize.width - frame.size.width, contentOffset)
        return contentOffset
    }
    
    private func updateSelectedBarYPosition() {
        var selectedBarFrame = selectedBar.frame
        
        switch selectedBarVerticalAlignment {
        case .top:
            selectedBarFrame.origin.y = 0
        case .middle:
            selectedBarFrame.origin.y = (frame.size.height - selectedBarHeight) / 2
        case .bottom:
            selectedBarFrame.origin.y = frame.size.height - selectedBarHeight
        }
        
        selectedBarFrame.size.height = selectedBarHeight
        selectedBar.frame = selectedBarFrame
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        updateSelectedBarYPosition()
    }
}

// MARK: Protocols

public protocol IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo
    
}

public protocol PagerTabStripDelegate: class {
    
    func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int)
}

public protocol PagerTabStripIsProgressiveDelegate: PagerTabStripDelegate {
    
    func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool)
}

public protocol PagerTabStripDataSource: class {
    
    func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController]
}

// MARK: PagerTabStripViewController

open class PagerTabStripViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak public var containerView: UIScrollView!
    
    open weak var delegate: PagerTabStripDelegate?
    open weak var datasource: PagerTabStripDataSource?
    
    open var pagerBehaviour = PagerTabStripBehaviour.progressive(skipIntermediateViewControllers: true, elasticIndicatorLimit: true)
    
    open private(set) var viewControllers = [UIViewController]()
    open private(set) var currentIndex = 0
    open private(set) var preCurrentIndex = 0 // used *only* to store the index to which move when the pager becomes visible
    
    open var pageWidth: CGFloat {
        return containerView.bounds.width
    }
    
    open var scrollPercentage: CGFloat {
        if swipeDirection != .right {
            let module = fmod(containerView.contentOffset.x, pageWidth)
            return module == 0.0 ? 1.0 : module / pageWidth
        }
        return 1 - fmod(containerView.contentOffset.x >= 0 ? containerView.contentOffset.x : pageWidth + containerView.contentOffset.x, pageWidth) / pageWidth
    }
    
    open var swipeDirection: SwipeDirection {
        if containerView.contentOffset.x > lastContentOffset {
            return .left
        } else if containerView.contentOffset.x < lastContentOffset {
            return .right
        }
        return .none
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        let conteinerViewAux = containerView ?? {
            let containerView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
            containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return containerView
            }()
        containerView = conteinerViewAux
        if containerView.superview == nil {
            view.addSubview(containerView)
        }
        containerView.bounces = true
        containerView.alwaysBounceHorizontal = true
        containerView.alwaysBounceVertical = false
        containerView.scrollsToTop = false
        containerView.delegate = self
        containerView.showsVerticalScrollIndicator = false
        containerView.showsHorizontalScrollIndicator = false
        containerView.isPagingEnabled = true
        reloadViewControllers()
        
        let childController = viewControllers[currentIndex]
        addChildViewController(childController)
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewAppearing = true
        childViewControllers.forEach { $0.beginAppearanceTransition(true, animated: animated) }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lastSize = containerView.bounds.size
        updateIfNeeded()
        let needToUpdateCurrentChild = preCurrentIndex != currentIndex
        if needToUpdateCurrentChild {
            moveToViewController(at: preCurrentIndex)
        }
        isViewAppearing = false
        childViewControllers.forEach { $0.endAppearanceTransition() }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        childViewControllers.forEach { $0.beginAppearanceTransition(false, animated: animated) }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        childViewControllers.forEach { $0.endAppearanceTransition() }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateIfNeeded()
    }
    
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    open func moveToViewController(at index: Int, animated: Bool = true) {
        guard isViewLoaded && view.window != nil && currentIndex != index else {
            preCurrentIndex = index
            return
        }
        
        if animated && pagerBehaviour.skipIntermediateViewControllers && abs(currentIndex - index) > 1 {
            var tmpViewControllers = viewControllers
            let currentChildVC = viewControllers[currentIndex]
            let fromIndex = currentIndex < index ? index - 1 : index + 1
            let fromChildVC = viewControllers[fromIndex]
            tmpViewControllers[currentIndex] = fromChildVC
            tmpViewControllers[fromIndex] = currentChildVC
            pagerTabStripChildViewControllersForScrolling = tmpViewControllers
            containerView.setContentOffset(CGPoint(x: pageOffsetForChild(at: fromIndex), y: 0), animated: false)
            (navigationController?.view ?? view).isUserInteractionEnabled = !animated
            containerView.setContentOffset(CGPoint(x: pageOffsetForChild(at: index), y: 0), animated: true)
        } else {
            (navigationController?.view ?? view).isUserInteractionEnabled = !animated
            containerView.setContentOffset(CGPoint(x: pageOffsetForChild(at: index), y: 0), animated: animated)
        }
    }
    
    open func moveTo(viewController: UIViewController, animated: Bool = true) {
        moveToViewController(at: viewControllers.index(of: viewController)!, animated: animated)
    }
    
    // MARK: - PagerTabStripDataSource
    
    open func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        assertionFailure("Sub-class must implement the PagerTabStripDataSource viewControllers(for:) method")
        return []
    }
    
    // MARK: - Helpers
    
    open func updateIfNeeded() {
        if isViewLoaded && !lastSize.equalTo(containerView.bounds.size) {
            updateContent()
        }
    }
    
    open func canMoveTo(index: Int) -> Bool {
        return currentIndex != index && viewControllers.count > index
    }
    
    open func pageOffsetForChild(at index: Int) -> CGFloat {
        return CGFloat(index) * containerView.bounds.width
    }
    
    open func offsetForChild(at index: Int) -> CGFloat {
        return (CGFloat(index) * containerView.bounds.width) + ((containerView.bounds.width - view.bounds.width) * 0.5)
    }
    
    open func offsetForChild(viewController: UIViewController) throws -> CGFloat {
        guard let index = viewControllers.index(of: viewController) else {
            throw PagerTabStripError.viewControllerOutOfBounds
        }
        return offsetForChild(at: index)
    }
    
    open func pageFor(contentOffset: CGFloat) -> Int {
        let result = virtualPageFor(contentOffset: contentOffset)
        return pageFor(virtualPage: result)
    }
    
    open func virtualPageFor(contentOffset: CGFloat) -> Int {
        return Int((contentOffset + 1.5 * pageWidth) / pageWidth) - 1
    }
    
    open func pageFor(virtualPage: Int) -> Int {
        if virtualPage < 0 {
            return 0
        }
        if virtualPage > viewControllers.count - 1 {
            return viewControllers.count - 1
        }
        return virtualPage
    }
    
    open func updateContent() {
        if lastSize.width != containerView.bounds.size.width {
            lastSize = containerView.bounds.size
            containerView.contentOffset = CGPoint(x: pageOffsetForChild(at: currentIndex), y: 0)
        }
        lastSize = containerView.bounds.size
        
        let pagerViewControllers = pagerTabStripChildViewControllersForScrolling ?? viewControllers
        containerView.contentSize = CGSize(width: containerView.bounds.width * CGFloat(pagerViewControllers.count), height: containerView.contentSize.height)
        
        for (index, childController) in pagerViewControllers.enumerated() {
            let pageOffsetForChild = self.pageOffsetForChild(at: index)
            if fabs(containerView.contentOffset.x - pageOffsetForChild) < containerView.bounds.width {
                if childController.parent != nil {
                    childController.view.frame = CGRect(x: offsetForChild(at: index), y: 0, width: view.bounds.width, height: containerView.bounds.height)
                    childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                } else {
                    childController.beginAppearanceTransition(true, animated: false)
                    addChildViewController(childController)
                    childController.view.frame = CGRect(x: offsetForChild(at: index), y: 0, width: view.bounds.width, height: containerView.bounds.height)
                    childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    containerView.addSubview(childController.view)
                    childController.didMove(toParentViewController: self)
                    childController.endAppearanceTransition()
                }
            } else {
                if childController.parent != nil {
                    childController.beginAppearanceTransition(false, animated: false)
                    childController.willMove(toParentViewController: nil)
                    childController.view.removeFromSuperview()
                    childController.removeFromParentViewController()
                    childController.endAppearanceTransition()
                }
            }
        }
        
        let oldCurrentIndex = currentIndex
        let virtualPage = virtualPageFor(contentOffset: containerView.contentOffset.x)
        let newCurrentIndex = pageFor(virtualPage: virtualPage)
        currentIndex = newCurrentIndex
        preCurrentIndex = currentIndex
        let changeCurrentIndex = newCurrentIndex != oldCurrentIndex
        
        if let progressiveDeledate = self as? PagerTabStripIsProgressiveDelegate, pagerBehaviour.isProgressiveIndicator {
            
            let (fromIndex, toIndex, scrollPercentage) = progressiveIndicatorData(virtualPage)
            progressiveDeledate.updateIndicator(for: self, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: scrollPercentage, indexWasChanged: changeCurrentIndex)
        } else {
            delegate?.updateIndicator(for: self, fromIndex: min(oldCurrentIndex, pagerViewControllers.count - 1), toIndex: newCurrentIndex)
        }
    }
    
    open func reloadPagerTabStripView() {
        guard isViewLoaded else { return }
        for childController in viewControllers where childController.parent != nil {
            childController.beginAppearanceTransition(false, animated: false)
            childController.willMove(toParentViewController: nil)
            childController.view.removeFromSuperview()
            childController.removeFromParentViewController()
            childController.endAppearanceTransition()
        }
        reloadViewControllers()
        containerView.contentSize = CGSize(width: containerView.bounds.width * CGFloat(viewControllers.count), height: containerView.contentSize.height)
        if currentIndex >= viewControllers.count {
            currentIndex = viewControllers.count - 1
        }
        preCurrentIndex = currentIndex
        containerView.contentOffset = CGPoint(x: pageOffsetForChild(at: currentIndex), y: 0)
        updateContent()
    }
    
    // MARK: - UIScrollDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if containerView == scrollView {
            updateContent()
            lastContentOffset = scrollView.contentOffset.x
        }
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if containerView == scrollView {
            lastPageNumber = pageFor(contentOffset: scrollView.contentOffset.x)
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if containerView == scrollView {
            pagerTabStripChildViewControllersForScrolling = nil
            (navigationController?.view ?? view).isUserInteractionEnabled = true
            updateContent()
        }
    }
    
    // MARK: - Orientation
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isViewRotating = true
        pageBeforeRotate = currentIndex
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let me = self else { return }
            me.isViewRotating = false
            me.currentIndex = me.pageBeforeRotate
            me.preCurrentIndex = me.currentIndex
            me.updateIfNeeded()
        }
    }
    
    // MARK: Private
    
    private func progressiveIndicatorData(_ virtualPage: Int) -> (Int, Int, CGFloat) {
        let count = viewControllers.count
        var fromIndex = currentIndex
        var toIndex = currentIndex
        let direction = swipeDirection
        
        if direction == .left {
            if virtualPage > count - 1 {
                fromIndex = count - 1
                toIndex = count
            } else {
                if self.scrollPercentage >= 0.5 {
                    fromIndex = max(toIndex - 1, 0)
                } else {
                    toIndex = fromIndex + 1
                }
            }
        } else if direction == .right {
            if virtualPage < 0 {
                fromIndex = 0
                toIndex = -1
            } else {
                if self.scrollPercentage > 0.5 {
                    fromIndex = min(toIndex + 1, count - 1)
                } else {
                    toIndex = fromIndex - 1
                }
            }
        }
        let scrollPercentage = pagerBehaviour.isElasticIndicatorLimit ? self.scrollPercentage : ((toIndex < 0 || toIndex >= count) ? 0.0 : self.scrollPercentage)
        return (fromIndex, toIndex, scrollPercentage)
    }
    
    private func reloadViewControllers() {
        guard let dataSource = datasource else {
            fatalError("dataSource must not be nil")
        }
        viewControllers = dataSource.viewControllers(for: self)
        // viewControllers
        guard !viewControllers.isEmpty else {
            fatalError("viewControllers(for:) should provide at least one child view controller")
        }
        viewControllers.forEach { if !($0 is IndicatorInfoProvider) { fatalError("Every view controller provided by PagerTabStripDataSource's viewControllers(for:) method must conform to  InfoProvider") }}
        
    }
    
    private var pagerTabStripChildViewControllersForScrolling: [UIViewController]?
    private var lastPageNumber = 0
    private var lastContentOffset: CGFloat = 0.0
    private var pageBeforeRotate = 0
    private var lastSize = CGSize(width: 0, height: 0)
    internal var isViewRotating = false
    internal var isViewAppearing = false
    
}

public enum SwipeDirection {
    case left
    case right
    case none
}

public enum PagerTabStripError: Error {
    
    case viewControllerOutOfBounds
    
}

open class ButtonBarViewCell: UICollectionViewCell {
    
    @IBOutlet open var imageView: UIImageView!
    @IBOutlet open var label: UILabel!
    
}

public enum PagerTabStripBehaviour {
    
    case common(skipIntermediateViewControllers: Bool)
    case progressive(skipIntermediateViewControllers: Bool, elasticIndicatorLimit: Bool)
    
    public var skipIntermediateViewControllers: Bool {
        switch self {
        case .common(let skipIntermediateViewControllers):
            return skipIntermediateViewControllers
        case .progressive(let skipIntermediateViewControllers, _):
            return skipIntermediateViewControllers
        }
    }
    
    public var isProgressiveIndicator: Bool {
        switch self {
        case .common:
            return false
        case .progressive:
            return true
        }
    }
    
    public var isElasticIndicatorLimit: Bool {
        switch self {
        case .common:
            return false
        case .progressive(_, let elasticIndicatorLimit):
            return elasticIndicatorLimit
        }
    }
}

