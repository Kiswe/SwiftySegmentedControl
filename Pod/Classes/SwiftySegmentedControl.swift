//
//  SwiftySegmentedControl.swift
//  SwiftySegmentedControl
//
//  Created by LiuYanghui on 2017/1/10.
//  Copyright © 2017年 Yanghui.Liu. All rights reserved.
//

import UIKit

// MARK: - SwiftySegmentedControl
@IBDesignable open class SwiftySegmentedControl: UIControl {
    // MARK: IndicatorView
    fileprivate class IndicatorView: UIView {
        // MARK: Properties
        fileprivate let titleMaskView = UIView()
        fileprivate let line = UIView()
        fileprivate let lineHeight: CGFloat = 2.0
        fileprivate var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                titleMaskView.layer.cornerRadius = cornerRadius
            }
        }
        override open var frame: CGRect {
            didSet {
                titleMaskView.frame = frame
                let lineFrame = CGRect(x: 0, y: frame.size.height - lineHeight, width: frame.size.width, height: lineHeight)
                line.frame = lineFrame
            }
        }
        
        open var lineColor = UIColor.clear {
            didSet {
                line.backgroundColor = lineColor
            }
        }
        
        // MARK: Lifecycle
        init() {
            super.init(frame: CGRect.zero)
            finishInit()
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            finishInit()
        }
        fileprivate func finishInit() {
            layer.masksToBounds = true
            titleMaskView.backgroundColor = UIColor.black
            addSubview(line)
        }
        
        override open func layoutSubviews() {
            super.layoutSubviews()
            
        }
    }
    
    // MARK: Constants
    fileprivate struct Animation {
        fileprivate static let withBounceDuration: TimeInterval = 0.3
        fileprivate static let springDamping: CGFloat = 0.75
        fileprivate static let withoutBounceDuration: TimeInterval = 0.2
    }
    fileprivate struct Color {
        fileprivate static let background: UIColor = UIColor.white
        fileprivate static let title: UIColor = UIColor.black
        fileprivate static let indicatorViewBackground: UIColor = UIColor.black
        fileprivate static let selectedTitle: UIColor = UIColor.white
    }
    
    // MARK: Error handling
    public enum IndexError: Error {
        case indexBeyondBounds(UInt)
    }
    
    // MARK: Properties
    /// The selected index
    public fileprivate(set) var index: UInt
    /// The titles / options available for selection
    public var titles: [String] {
        get {
            let titleLabels = titleLabelsView.subviews as! [UILabel]
            return titleLabels.map { $0.text! }
        }
        set {
            guard newValue.count > 1 else {
                return
            }
            let labels: [(UILabel, UILabel)] = newValue.map {
                (string) -> (UILabel, UILabel) in
                
                let titleLabel = UILabel()
                titleLabel.textColor = titleColor
                titleLabel.text = string
                titleLabel.lineBreakMode = .byTruncatingTail
                titleLabel.textAlignment = .center
                titleLabel.font = titleFont
                titleLabel.layer.borderWidth = titleBorderWidth
                titleLabel.layer.borderColor = titleBorderColor
                titleLabel.layer.cornerRadius = indicatorView.cornerRadius
                
                let selectedTitleLabel = UILabel()
                selectedTitleLabel.textColor = selectedTitleColor
                selectedTitleLabel.text = string
                selectedTitleLabel.lineBreakMode = .byTruncatingTail
                selectedTitleLabel.textAlignment = .center
                selectedTitleLabel.font = selectedTitleFont
                
                return (titleLabel, selectedTitleLabel)
            }
            
            titleLabelsView.subviews.forEach({ $0.removeFromSuperview() })
            selectedTitleLabelsView.subviews.forEach({ $0.removeFromSuperview() })
            
            for (inactiveLabel, activeLabel) in labels {
                titleLabelsView.addSubview(inactiveLabel)
                selectedTitleLabelsView.addSubview(activeLabel)
            }
            
            setNeedsLayout()
        }
    }
    /// Whether the indicator should bounce when selecting a new index. Defaults to true
    public var bouncesOnChange = true
    /// Whether the the control should always send the .ValueChanged event, regardless of the index remaining unchanged after interaction. Defaults to false
    public var alwaysAnnouncesValue = false
    /// Whether to send the .ValueChanged event immediately or wait for animations to complete. Defaults to true
    public var announcesValueImmediately = true
    /// Whether the the control should ignore pan gestures. Defaults to false
    public var panningDisabled = false
    /// The control's and indicator's corner radii
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            indicatorView.cornerRadius = newValue - indicatorViewInset
            titleLabels.forEach { $0.layer.cornerRadius = indicatorView.cornerRadius }
        }
    }
    /// The indicator view's background color
    @IBInspectable public var indicatorViewBackgroundColor: UIColor? {
        get {
            return indicatorView.backgroundColor
        }
        set {
            indicatorView.backgroundColor = newValue
        }
    }
    /// Margin spacing between titles. Default to 33.
    @IBInspectable public var marginSpace: CGFloat = 33 {
        didSet { setNeedsLayout() }
    }
    /// The indicator view's inset. Defaults to 2.0
    @IBInspectable public var indicatorViewInset: CGFloat = 2.0 {
        didSet { setNeedsLayout() }
    }
    /// The indicator view's border width
    public var indicatorViewBorderWidth: CGFloat {
        get {
            return indicatorView.layer.borderWidth
        }
        set {
            indicatorView.layer.borderWidth = newValue
        }
    }
    /// The indicator view's border width
    public var indicatorViewBorderColor: CGColor? {
        get {
            return indicatorView.layer.borderColor
        }
        set {
            indicatorView.layer.borderColor = newValue
        }
    }
    /// The indicator view's line color
    public var indicatorViewLineColor: UIColor {
        get {
            return indicatorView.lineColor
        }
        set {
            indicatorView.lineColor = newValue
        }
    }
    /// The text color of the non-selected titles / options
    @IBInspectable public var titleColor: UIColor  {
        didSet {
            titleLabels.forEach { $0.textColor = titleColor }
        }
    }
    /// The text color of the selected title / option
    @IBInspectable public var selectedTitleColor: UIColor {
        didSet {
            selectedTitleLabels.forEach { $0.textColor = selectedTitleColor }
        }
    }
    /// The titles' font
    public var titleFont: UIFont = UILabel().font {
        didSet {
            titleLabels.forEach { $0.font = titleFont }
        }
    }
    /// The selected title's font
    public var selectedTitleFont: UIFont = UILabel().font {
        didSet {
            selectedTitleLabels.forEach { $0.font = selectedTitleFont }
        }
    }
    /// The titles' border width
    public var titleBorderWidth: CGFloat = 0.0 {
        didSet {
            titleLabels.forEach { $0.layer.borderWidth = titleBorderWidth }
        }
    }
    /// The titles' border color
    public var titleBorderColor: CGColor = UIColor.clear.cgColor {
        didSet {
            titleLabels.forEach { $0.layer.borderColor = titleBorderColor }
        }
    }
    
    // MARK: - Private properties
    fileprivate let contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    fileprivate let titleLabelsView = UIView()
    fileprivate let selectedTitleLabelsView = UIView()
    fileprivate let indicatorView = IndicatorView()
    fileprivate var initialIndicatorViewFrame: CGRect?
    
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer!
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
    
    fileprivate var width: CGFloat { return bounds.width }
    fileprivate var height: CGFloat { return bounds.height }
    fileprivate var titleLabelsCount: Int { return titleLabelsView.subviews.count }
    fileprivate var titleLabels: [UILabel] { return titleLabelsView.subviews as! [UILabel] }
    fileprivate var selectedTitleLabels: [UILabel] { return selectedTitleLabelsView.subviews as! [UILabel] }
    fileprivate var totalInsetSize: CGFloat { return indicatorViewInset * 2.0 }
    fileprivate lazy var defaultTitles: [String] = { return ["First", "Second"] }()
    fileprivate var titlesWidth: [CGFloat] {
        return titles.map {
            let statusLabelText: NSString = $0 as NSString
            let size = CGSize(width: width, height: height - totalInsetSize)
            let dic: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
            let strSize = statusLabelText.boundingRect(with: size,
                                                       options: .usesLineFragmentOrigin,
                                                       attributes: dic,
                                                       context: nil).size
            return strSize.width
        }
    }
    
    // MARK: Lifecycle
    required public init?(coder aDecoder: NSCoder) {
        index = 0
        titleColor = Color.title
        selectedTitleColor = Color.selectedTitle
        super.init(coder: aDecoder)
        titles = defaultTitles
        finishInit()
    }
    public init(frame: CGRect,
                titles: [String],
                index: UInt,
                backgroundColor: UIColor,
                titleColor: UIColor,
                indicatorViewBackgroundColor: UIColor,
                selectedTitleColor: UIColor) {
        self.index = index
        self.titleColor = titleColor
        self.selectedTitleColor = selectedTitleColor
        super.init(frame: frame)
        self.titles = titles
        self.backgroundColor = backgroundColor
        self.indicatorViewBackgroundColor = indicatorViewBackgroundColor
        finishInit()
    }
    
    @available(*, deprecated, message: "Use init(frame:titles:index:backgroundColor:titleColor:indicatorViewBackgroundColor:selectedTitleColor:) instead.")
    convenience override public init(frame: CGRect) {
        self.init(frame: frame,
                  titles: ["First", "Second"],
                  index: 0,
                  backgroundColor: Color.background,
                  titleColor: Color.title,
                  indicatorViewBackgroundColor: Color.indicatorViewBackground,
                  selectedTitleColor: Color.selectedTitle)
    }
    
    @available(*, unavailable, message: "Use init(frame:titles:index:backgroundColor:titleColor:indicatorViewBackgroundColor:selectedTitleColor:) instead.")
    convenience init() {
        self.init(frame: CGRect.zero,
                  titles: ["First", "Second"],
                  index: 0,
                  backgroundColor: Color.background,
                  titleColor: Color.title,
                  indicatorViewBackgroundColor: Color.indicatorViewBackground,
                  selectedTitleColor: Color.selectedTitle)
    }

    
    fileprivate func finishInit() {
        layer.masksToBounds = true
        
        addSubview(contentScrollView)
        contentScrollView.addSubview(titleLabelsView)
        contentScrollView.addSubview(indicatorView)
        contentScrollView.addSubview(selectedTitleLabelsView)
        selectedTitleLabelsView.layer.mask = indicatorView.titleMaskView.layer
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SwiftySegmentedControl.tapped(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwiftySegmentedControl.panned(_:)))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        guard titleLabelsCount > 1 else {
            return
        }
        
        contentScrollView.frame = bounds
        let allElementsWidth = titlesWidth.reduce(0, {$0 + $1}) + CGFloat(titleLabelsCount) * marginSpace
        contentScrollView.contentSize = CGSize(width: max(allElementsWidth, width), height: 0)
        
        titleLabelsView.frame = bounds
        selectedTitleLabelsView.frame = bounds
        
        indicatorView.frame = elementFrame(forIndex: index)
        
        for index in 0...titleLabelsCount-1 {
            let frame = elementFrame(forIndex: UInt(index))
            titleLabelsView.subviews[index].frame = frame
            selectedTitleLabelsView.subviews[index].frame = frame
        }
    }
    
    // MARK: Index Setting
    /*!
     Sets the control's index.
     
     - parameter index:    The new index
     - parameter animated: (Optional) Whether the change should be animated or not. Defaults to true.
     
     - throws: An error of type IndexBeyondBounds(UInt) is thrown if an index beyond the available indices is passed.
     */
    public func setIndex(_ index: UInt, animated: Bool = true) throws {
        guard titleLabels.indices.contains(Int(index)) else {
            throw IndexError.indexBeyondBounds(index)
        }
        let oldIndex = self.index
        self.index = index
        moveIndicatorViewToIndex(animated, shouldSendEvent: (self.index != oldIndex || alwaysAnnouncesValue))
        fixedScrollViewOffset(Int(self.index))
    }
    
    // MARK: Fixed ScrollView offset
    fileprivate func fixedScrollViewOffset(_ focusIndex: Int) {
        guard contentScrollView.contentSize.width > width else {
            return
        }
        
        let targetMidX = self.titleLabels[Int(self.index)].frame.midX
        let offsetX = contentScrollView.contentOffset.x
        let addOffsetX = targetMidX - offsetX - width / 2
        let newOffSetX = min(max(0, offsetX + addOffsetX), contentScrollView.contentSize.width - width)
        let point = CGPoint(x: newOffSetX, y: contentScrollView.contentOffset.y)
        contentScrollView.setContentOffset(point, animated: true)
    }
    
    // MARK: Animations
    fileprivate func moveIndicatorViewToIndex(_ animated: Bool, shouldSendEvent: Bool) {
        if animated {
            if shouldSendEvent && announcesValueImmediately {
                sendActions(for: .valueChanged)
            }
            UIView.animate(withDuration: bouncesOnChange ? Animation.withBounceDuration : Animation.withoutBounceDuration,
                           delay: 0.0,
                           usingSpringWithDamping: bouncesOnChange ? Animation.springDamping : 1.0,
                           initialSpringVelocity: 0.0,
                           options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseOut],
                           animations: {
                            () -> Void in
                            self.moveIndicatorView()
            }, completion: { (finished) -> Void in
                if finished && shouldSendEvent && !self.announcesValueImmediately {
                    self.sendActions(for: .valueChanged)
                }
            })
        } else {
            moveIndicatorView()
            sendActions(for: .valueChanged)
        }
    }
    
    // MARK: Helpers
    fileprivate func elementFrame(forIndex index: UInt) -> CGRect {
        // 计算出label的宽度，label宽度 = (text宽度) + marginSpace
        // | <= 0.5 * marginSpace => text1 <= 0.5 * marginSpace => | <= 0.5 * marginSpace => text2 <= 0.5 * marginSpace => |
        // 如果总宽度小于bunds.width，则均分宽度 label宽度 = bunds.width / count
        let allElementsWidth = titlesWidth.reduce(0, {$0 + $1}) + CGFloat(titleLabelsCount) * marginSpace
        if allElementsWidth < width {
            let elementWidth = (width - totalInsetSize) / CGFloat(titleLabelsCount)
            return CGRect(x: CGFloat(index) * elementWidth + indicatorViewInset,
                          y: indicatorViewInset,
                          width: elementWidth,
                          height: height - totalInsetSize)
        } else {
            let titlesWidth = self.titlesWidth
            let frontTitlesWidth = titlesWidth.enumerated().reduce(CGFloat(0)) { (total, current) in
                return current.0 < Int(index) ? total + current.1 : total
            }
            let x = frontTitlesWidth + CGFloat(index) * marginSpace
            return CGRect(x: x,
                          y: indicatorViewInset,
                          width: titlesWidth[Int(index)] + marginSpace,
                          height: height - totalInsetSize)
        }
    }
    fileprivate func nearestIndex(toPoint point: CGPoint) -> UInt {
        let distances = titleLabels.map { abs(point.x - $0.center.x) }
        return UInt(distances.index(of: distances.min()!)!)
    }
    fileprivate func moveIndicatorView() {
        indicatorView.frame = titleLabels[Int(self.index)].frame
        layoutIfNeeded()
    }
    
    // MARK: Action handlers
    @objc fileprivate func tapped(_ gestureRecognizer: UITapGestureRecognizer!) {
        let location = gestureRecognizer.location(in: contentScrollView)
        try! setIndex(nearestIndex(toPoint: location))
    }
    @objc fileprivate func panned(_ gestureRecognizer: UIPanGestureRecognizer!) {
        guard !panningDisabled else {
            return
        }
        
        switch gestureRecognizer.state {
        case .began:
            initialIndicatorViewFrame = indicatorView.frame
        case .changed:
            var frame = initialIndicatorViewFrame!
            frame.origin.x += gestureRecognizer.translation(in: self).x
            frame.origin.x = max(min(frame.origin.x, bounds.width - indicatorViewInset - frame.width), indicatorViewInset)
            indicatorView.frame = frame
        case .ended, .failed, .cancelled:
            try! setIndex(nearestIndex(toPoint: indicatorView.center))
        default: break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SwiftySegmentedControl: UIGestureRecognizerDelegate {
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            return indicatorView.frame.contains(gestureRecognizer.location(in: contentScrollView))
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
