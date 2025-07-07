//
//  Created by Jovanni Lo (@lodev09)
//  Copyright (c) 2024-present. All rights reserved.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//

@objc(TrueSheetView)
class TrueSheetView: UIView, RCTInvalidating, TrueSheetViewControllerDelegate {
  // MARK: - React properties

  // MARK: - Events

  @objc var onMount: RCTDirectEventBlock?
  @objc var onDismiss: RCTDirectEventBlock?
  @objc var onPresent: RCTDirectEventBlock?
  @objc var onSizeChange: RCTDirectEventBlock?
  @objc var onContainerSizeChange: RCTDirectEventBlock?
  @objc var onDragBegin: RCTDirectEventBlock?
  @objc var onDragChange: RCTDirectEventBlock?
  @objc var onDragEnd: RCTDirectEventBlock?

  // MARK: - React Properties

  @objc var initialIndex: NSNumber = -1
  @objc var initialIndexAnimated = true

  // MARK: - Private properties

  private var isPresented = false
  private var activeIndex: Int?
  private var bridge: RCTBridge?
  private var eventDispatcher: (any RCTEventDispatcherProtocol)?
  private var viewController: TrueSheetViewController

  private var touchHandler: RCTTouchHandler
  // New Arch
  private var surfaceTouchHandler: RCTSurfaceTouchHandler

  // MARK: - Content properties
  private var keyboardAvoidingView: UIView
  
  private var containerView: UIView?
  private var contentView: UIView?
  private var headerView: UIView?
  private var footerView: UIView?
  private var scrollView: UIView?

  // Bottom: Reference the bottom constraint to adjust during keyboard event
  // Height: Reference height constraint during content updates
  private var footerConstraints: Constraints?
  // Height: Reference height constraint during content updates
  private var headerConstraints: Constraints?
  private var contentConstraints: Constraints?

  private var uiManager: RCTUIManager? {
    guard let uiManager = bridge?.uiManager else { return nil }
    return uiManager
  }

  // MARK: - Setup

  init(with bridge: RCTBridge) {
    self.bridge = bridge
    eventDispatcher = bridge.eventDispatcher()

    viewController = TrueSheetViewController()
    touchHandler = RCTTouchHandler(bridge: bridge)
    surfaceTouchHandler = RCTSurfaceTouchHandler()

    let rect = CGRect(x: 0, y: 0, width: 0, height: 0)
    keyboardAvoidingView = UIView(frame: rect)

    super.init(frame: .zero)
    
    viewController.delegate = self
    
//    containerView.keyboardLayoutGuide.followsUndockedKeyboard = true
//    let cons = containerView.bottomAnchor.constraint(equalTo: containerView.keyboardLayoutGuide.topAnchor)
//    cons.isActive = true
//    containerView.addConstraint(cons)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func insertReactSubview(_ subview: UIView!, at index: Int) {
//    super.insertReactSubview(subview, at: index)
    guard containerView == nil else {
      Logger.error("Sheet can only have one content view.")
      return
    }

    let cv = viewController.view!;
    cv.addSubview(keyboardAvoidingView)

    keyboardAvoidingView.accessibilityLabel = "Avoider"
//    keyboardAvoidingView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleRightMargin, .flexibleBottomMargin]
    keyboardAvoidingView.backgroundColor = .cyan
//    keyboardAvoidingView.clipsToBounds = true
    keyboardAvoidingView.translatesAutoresizingMaskIntoConstraints = false
    let constraints: [NSLayoutConstraint] = [
      cv.topAnchor.constraint(equalTo: keyboardAvoidingView.topAnchor),
//      cv.bottomAnchor.constraint(equalTo: keyboardAvoidingView.bottomAnchor),
      cv.leadingAnchor.constraint(equalTo: keyboardAvoidingView.leadingAnchor),
      cv.trailingAnchor.constraint(equalTo: keyboardAvoidingView.trailingAnchor),
    ]
    for c in constraints {
      c.isActive = true
//      c.priority = UILayoutPriority(1.0)
      cv.addConstraint(c)
    }
    
    let bottom = cv.keyboardLayoutGuide.topAnchor.constraint(equalTo: keyboardAvoidingView.bottomAnchor)
//    let bottom = keyboardAvoidingView.keyboardLayoutGuide.topAnchor.constraint(equalTo: keyboardAvoidingView.bottomAnchor)
//    bottom.priority = UILayoutPriority(20.0)
    if #available(iOS 17.0, *) {
      cv.keyboardLayoutGuide.usesBottomSafeArea = false
    }
//    let trailing = cv.keyboardLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: keyboardAvoidingView.trailingAnchor, multiplier: 1.0)
    NSLayoutConstraint.activate([bottom])
    cv.addConstraint(bottom)
    cv.keyboardLayoutGuide.setConstraints([bottom], activeWhenNearEdge: .bottom)
//    cv.addConstraint(trailing)

    keyboardAvoidingView.insertReactSubview(subview, at: index)
    keyboardAvoidingView.addSubview(subview)

    containerView = subview
    
//    viewController.view.addSubview(subview)
    touchHandler.attach(to: subview)
    surfaceTouchHandler.attach(to: subview)
  }
  
  override func removeReactSubview(_ subview: UIView!) {
    guard subview == containerView else {
      Logger.error("Cannot remove view other than sheet view")
      return
    }

//    keyboardAvoidingView.removeReactSubview(subview)
//    super.removeReactSubview(subview)

    // Touch handler for Old Arch
    touchHandler.detach(from: subview)

    // Touch handler that works in New Arch
    surfaceTouchHandler.detach(from: subview)

    // Remove all constraints
    // Fixes New Arch weird layout issue :/
//    removeAllConstraints(from: [footerView])
//    scrollView?.unpin()

    containerView = nil
    contentView = nil
    headerView = nil
    footerView = nil
    scrollView = nil
  }

  func removeAllConstraints(from views: [UIView?]) {
      views.forEach { view in
        view?.translatesAutoresizingMaskIntoConstraints = true
        if let constraints = view?.constraints {
          view?.removeConstraints(constraints)
        }
      }
  }

  override func didUpdateReactSubviews() {
    // Do nothing, as subviews are managed by `insertReactSubview`
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if let containerView, contentView == nil {
      headerView = containerView.subviews[0]
      contentView = containerView.subviews[1]
      footerView = containerView.subviews[2]

      guard let contentView, let footerView, let headerView else {
        Logger.error("Missing the required views")
        return
      }

      //containerView.translatesAutoresizingMaskIntoConstraints = false
//      keyboardLayoutGuide.topAnchor.constraint(equalToSystemSpacingBelow: bottomAnchor, multiplier: 1.0).isActive = true
//      let buttonBottom = containerView.keyboardLayoutGuide.topAnchor.constraint(equalToSystemSpacingBelow: footerView.bottomAnchor, multiplier: 1.0)
//      let buttonTrailing = containerView.keyboardLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: footerView.trailingAnchor, multiplier: 1.0)
//      NSLayoutConstraint.activate([buttonBottom, buttonTrailing])
//      containerView.keyboardLayoutGuide.followsUndockedKeyboard = true
      
//      Logger.info(headerView.nativeID)
//      Logger.info(contentView.nativeID)
//      Logger.info(footerView.nativeID)

      // Remove all the constraints coming from React
//      removeAllConstraints(from: [headerView, contentView, footerView, containerView])

      // Container view fills the entire view controller
//      containerView.pinTo(view: viewController.view, constraints: nil)
//
//      // Pin header to the top
//      headerView.pinTo(view: containerView, from: [.left, .right, .top]) { constraints in
//        self.headerConstraints = constraints
//      }
//
////      // Pin footer to the bottom
//      footerView.pinTo(view: containerView, from: [.left, .right, .bottom]) { constraints in
//        self.footerConstraints = constraints
//      }
//
//      // Pin content view between header and footer
//      contentView.pinTo(view: containerView, from: [.left, .right]) { constraints in
//        self.contentConstraints = constraints
//      }
//
//      contentView.topAnchor.constraint(
//        equalTo: headerView.bottomAnchor
//      ).isActive = true
//      footerView.topAnchor.constraint(
//        equalTo: contentView.bottomAnchor
//      ).isActive = true

      // Set initial content height
      let contentHeight = contentView.bounds.height
      setContentHeight(NSNumber(value: contentHeight))
      // ...and set initial footer/header heights. This calls back into the controller
      // and adjusts the view size to account for the footer.
      let footerHeight = footerView.bounds.height
      setFooterHeight(NSNumber(value: footerHeight))
      let headerHeight = headerView.bounds.height
      setHeaderHeight(NSNumber(value: headerHeight))

      // Present sheet at initial index
      let initialIndex = self.initialIndex.intValue
      if initialIndex >= 0 {
        present(at: initialIndex, promise: nil, animated: initialIndexAnimated)
      }

      dispatchEvent(name: "onMount", block: onMount, data: nil)
    }
  }

  // MARK: - ViewController delegate

  func viewControllerDidChangeDimensions() {
    let bounds = keyboardAvoidingView.bounds
    dispatchEvent(name: "onContainerSizeChange", block: onContainerSizeChange,
                  data: ["width": bounds.width, "height": bounds.height])
  }

  func viewControllerDidDrag(_ state: UIGestureRecognizer.State, _ height: CGFloat) {
    let sizeInfo = SizeInfo(index: activeIndex ?? 0, value: height)

    switch state {
    case .began:
      dispatchEvent(name: "onDragBegin", block: onDragBegin, data: sizeInfoData(from: sizeInfo))
    case .changed:
      dispatchEvent(name: "onDragChange", block: onDragChange, data: sizeInfoData(from: sizeInfo))
    case .ended, .cancelled:
      dispatchEvent(name: "onDragEnd", block: onDragEnd, data: sizeInfoData(from: sizeInfo))
    default:
      Logger.info("Drag state is not supported")
    }
  }

  func viewControllerWillAppear() {
    guard let contentView, let scrollView, let containerView else {
      return
    }

    // Add constraints to fix weirdness and support ScrollView
    // contentView.pinTo(view: containerView, constraints: nil)
    // scrollView.pinTo(view: contentView, constraints: nil)
  }

  func viewControllerDidDismiss() {
    isPresented = false
    activeIndex = nil
    dispatchEvent(name: "onDismiss", block: onDismiss, data: nil)
  }

  func viewControllerDidChangeSize(_ sizeInfo: SizeInfo?) {
    Logger.info("Size has been changed!")
    guard let sizeInfo else { return }

    if sizeInfo.index != activeIndex {
      activeIndex = sizeInfo.index
      dispatchEvent(name: "onSizeChange", block: onSizeChange, data: sizeInfoData(from: sizeInfo))
    }
  }

  func invalidate() {
    viewController.dismiss(animated: true)
  }

  // MARK: - Prop setters

  @objc
  func setDismissible(_ dismissible: Bool) {
    viewController.isModalInPresentation = !dismissible
  }

  @objc
  func setMaxHeight(_ height: NSNumber) {
    let maxHeight = CGFloat(height.floatValue)
    guard viewController.maxHeight != maxHeight else {
      return
    }

    viewController.maxHeight = maxHeight

    if #available(iOS 15.0, *) {
      withPresentedSheet { _ in
        viewController.setupSizes()
      }
    }
  }

  @objc
  func setContentHeight(_ height: NSNumber) {
    let contentHeight = CGFloat(height.floatValue)
    guard viewController.contentHeight != contentHeight else {
      return
    }

    viewController.contentHeight = contentHeight
//    contentConstraints?.height?.constant = contentHeight

    if #available(iOS 15.0, *) {
      withPresentedSheet { _ in
        viewController.setupSizes()
      }
    }
  }

  @objc
  func setHeaderHeight(_ height: NSNumber) {
    let headerHeight = CGFloat(height.floatValue)
    guard let headerView, viewController.headerHeight != headerHeight else {
      return
    }

    viewController.headerHeight = headerHeight

    if #available(iOS 15.0, *) {
      withPresentedSheet { _ in
        viewController.setupSizes()
      }
    }
  }

  @objc
  func setFooterHeight(_ height: NSNumber) {
    let footerHeight = CGFloat(height.floatValue)
    guard let footerView, viewController.footerHeight != footerHeight else {
      return
    }

    viewController.footerHeight = footerHeight

    if #available(iOS 15.0, *) {
      withPresentedSheet { _ in
        viewController.setupSizes()
      }
    }
  }

  @objc
  func setSizes(_ sizes: [Any]) {
    viewController.sizes = Array(sizes.prefix(3))

    if #available(iOS 15.0, *) {
      withPresentedSheet { _ in
        viewController.setupSizes()
      }
    }
  }

  @objc
  func setBackground(_ color: NSNumber?) {
    viewController.backgroundColor = RCTConvert.uiColor(color)
    viewController.setupBackground()
  }

  @objc
  func setBlurTint(_ tint: NSString?) {
    if let tint {
      viewController.blurEffect = UIBlurEffect(with: tint as String)
    } else {
      viewController.blurEffect = nil
    }

    viewController.setupBackground()
  }

  @objc
  func setCornerRadius(_ radius: NSNumber?) {
    var cornerRadius: CGFloat?

    if let radius {
      cornerRadius = CGFloat(radius.floatValue)
    }

    viewController.cornerRadius = cornerRadius
    if #available(iOS 15.0, *) {
      withPresentedSheet { sheet in
        sheet.preferredCornerRadius = viewController.cornerRadius
      }
    }
  }

  @objc
  func setGrabber(_ visible: Bool) {
    viewController.grabber = visible

    if #available(iOS 15.0, *) {
      withPresentedSheet { sheet in
        sheet.prefersGrabberVisible = visible
      }
    }
  }

  @objc
  func setDimmed(_ dimmed: Bool) {
    guard viewController.dimmed != dimmed else {
      return
    }

    viewController.dimmed = dimmed

    if #available(iOS 15.0, *) {
      withPresentedSheet { _ in
        viewController.setupDimmedBackground()
      }
    }
  }

  @objc
  func setDimmedIndex(_ index: NSNumber) {
    guard viewController.dimmedIndex != index.intValue else {
      return
    }

    viewController.dimmedIndex = index.intValue

    if #available(iOS 15.0, *) {
      withPresentedSheet { _ in
        viewController.setupDimmedBackground()
      }
    }
  }

  @objc
  func setScrollableHandle(_ tag: NSNumber?) {
    scrollView = uiManager?.view(forReactTag: tag)
    
//    let scroller = scrollView?.inputViewController?.contentScrollView(for: NSDirectionalRectEdge.trailing)
//    viewController.setContentScrollView(scroller, for: NSDirectionalRectEdge.trailing)
  }

  // MARK: - Methods

  private func sizeInfoData(from sizeInfo: SizeInfo?) -> [String: Any]? {
    guard let sizeInfo else {
      return nil
    }

    return ["index": sizeInfo.index, "value": sizeInfo.value]
  }

  /// Use to customize some properties of the Sheet without fully reconfiguring.
  @available(iOS 15.0, *)
  func withPresentedSheet(completion: (UISheetPresentationController) -> Void) {
    guard isPresented, let sheet = viewController.sheetPresentationController else {
      return
    }

    sheet.animateChanges {
      completion(sheet)
    }
  }

  func dispatchEvent(name: String, block: RCTDirectEventBlock?, data: [String: Any]?) {
    // eventDispatcher doesn't work in New Arch so we need to call it directly :/
    // we needed eventDispatcher for Reanimated to work on old arch.
    #if RCT_NEW_ARCH_ENABLED
      block?(data)
    #else
      eventDispatcher?.send(TrueSheetEvent(viewTag: reactTag, name: name, data: data))
    #endif
  }

  func dismiss(promise: Promise) {
    guard isPresented else {
      promise.resolve(nil)
      return
    }

    viewController.dismiss(animated: true) {
      promise.resolve(nil)
    }
  }

  func present(at index: Int, promise: Promise?, animated: Bool = true) {
    let rvc = reactViewController()

    guard let rvc else {
      promise?.reject(message: "No react view controller present.")
      return
    }

    guard viewController.sizes.indices.contains(index) else {
      promise?.reject(message: "Size at \(index) is not configured.")
      return
    }

    if isPresented {
      withPresentedSheet { sheet in
        sheet.selectedDetentIdentifier = viewController.detentIdentifierForIndex(index)

        // Trigger onSizeChange event when size is changed while presenting
        viewControllerDidChangeSize(self.viewController.currentSizeInfo)
        promise?.resolve(nil)
      }
    } else {
      viewController.prepareForPresentation(at: index) {
        // Keep track of the active index
        self.activeIndex = index
        self.isPresented = true

        rvc.present(self.viewController, animated: animated) {
          if #available(iOS 15.0, *) {
            self.viewController.observeDrag()
          }

          let data = self.sizeInfoData(from: self.viewController.currentSizeInfo)
          self.dispatchEvent(name: "onPresent", block: self.onPresent, data: data)
          promise?.resolve(nil)
        }
      }
    }
  }
}
