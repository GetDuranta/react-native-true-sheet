package com.lodev09.truesheet.core

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.View.MeasureSpec.AT_MOST
import com.facebook.react.ReactRootView
import com.facebook.react.config.ReactFeatureFlags
import com.facebook.react.uimanager.JSPointerDispatcher
import com.facebook.react.uimanager.JSTouchDispatcher
import com.facebook.react.uimanager.RootViewUtil.getViewportOffset
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.events.EventDispatcher
import com.lodev09.truesheet.TrueSheetDialog.Companion.TAG

/**
 * RootSheetView is the ViewGroup which contains all the children of a Modal. It now
 * doesn't need to do any layout trickery, as it's fully handled by the TrueSheetView
 * that sends the dimensions back to the React world.
 *
 * Its only responsibility now is to dispatch the touch events.
 */
class RootSheetView(private val context: Context?) :
  ReactRootView(context) {
  private val jSTouchDispatcher = JSTouchDispatcher(this)
  private var jSPointerDispatcher: JSPointerDispatcher? = null

  var eventDispatcher: EventDispatcher? = null

  var pinning = false;
  private var minHeightWithoutPinning = 0;

  private val reactContext: ThemedReactContext
    get() = context as ThemedReactContext

  init {
    if (ReactFeatureFlags.dispatchPointerEvents) {
      jSPointerDispatcher = JSPointerDispatcher(this)
    }
  }

  override fun handleException(t: Throwable) {
    reactContext.reactApplicationContext.handleException(RuntimeException(t))
  }

  override fun onInterceptTouchEvent(event: MotionEvent): Boolean {
    eventDispatcher?.let { eventDispatcher ->
      jSTouchDispatcher.handleTouchEvent(event, eventDispatcher, reactContext)
      jSPointerDispatcher?.handleMotionEvent(event, eventDispatcher, true)
    }
    return super.onInterceptTouchEvent(event)
  }

  @SuppressLint("ClickableViewAccessibility")
  override fun onTouchEvent(event: MotionEvent): Boolean {
    eventDispatcher?.let { eventDispatcher ->
      jSTouchDispatcher.handleTouchEvent(event, eventDispatcher, reactContext)
      jSPointerDispatcher?.handleMotionEvent(event, eventDispatcher, false)
    }
    super.onTouchEvent(event)
    // In case when there is no children interested in handling touch event, we return true from
    // the root view in order to receive subsequent events related to that gesture
    return true
  }

  override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
    Log.v(TAG, "Layout measured: ${measuredHeight}, height ${bottom-top}")
    super.onLayout(changed, left, top, right, bottom)
  }

  override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
    val spec = MeasureSpec.toString(heightMeasureSpec)
    val mode = MeasureSpec.getMode(heightMeasureSpec)
    val offeredHeight = MeasureSpec.getSize(heightMeasureSpec)
//    Log.v(TAG, "Measuring: ${mode}, $height")
//    val heightMeasureSpec2 = MeasureSpec.makeMeasureSpec(1000, mode)
//    layoutParams.height = 1000
    super.onMeasure(widthMeasureSpec, heightMeasureSpec)

//    pinning = mode == AT_MOST && measuredHeight >= offeredHeight;
//    if (pinning && minHeightWithoutPinning < offeredHeight) {
//      minHeightWithoutPinning = offeredHeight
//    }
//    if (!pinning && offeredHeight <= minHeightWithoutPinning) {
//      pinning = true
//    }
//    if (offeredHeight > measuredHeight) {
//      pinning = true
//    }
//
//    if (mode == AT_MOST && measuredHeight > offeredHeight) {
//      // We actually can scale to ANY height
//      //setMeasuredDimension(measuredWidth, offeredHeight)
//      //updateRootLayoutSpecs(true, widthMeasureSpec, heightMeasureSpec)
//    }

    if (mode == AT_MOST && offeredHeight > measuredHeight) {
      setMeasuredDimension(measuredWidth, offeredHeight)
    }

    Log.v(TAG, "Spec ${spec}, measured: ${measuredHeight}")
  }

  /**
   * Call whenever measure specs change, or if you want to force an update of offsetX/offsetY. If
   * measureSpecsChanged is false and the offsetX/offsetY don't change, updateRootLayoutSpecs will
   * not be called on the UIManager as a perf optimization.
   *
   * @param measureSpecsChanged
   * @param widthMeasureSpec
   * @param heightMeasureSpec
   */
  private fun updateRootLayoutSpecs(
    measureSpecsChanged: Boolean, widthMeasureSpec: Int, heightMeasureSpec: Int
  ) {
    // In Fabric we cannot call `updateRootLayoutSpecs` until a SurfaceId has been set.
    // Sometimes,
    val isFabricEnabled = false

    val uiManager =
      UIManagerHelper.getUIManager(reactContext, uiManagerType)
    // Ignore calling updateRootLayoutSpecs if UIManager is not properly initialized.
    if (uiManager != null) {
      // In Fabric only, get position of view within screen
      var offsetX = 0
      var offsetY = 0
      if (isFabricEnabled) {
        val viewportOffset = getViewportOffset(this)
        offsetX = viewportOffset.x
        offsetY = viewportOffset.y
      }

      if (measureSpecsChanged) {
        uiManager.updateRootLayoutSpecs(
          rootViewTag, widthMeasureSpec, heightMeasureSpec, offsetX, offsetY
        )
      }
    }
  }

  override fun onInterceptHoverEvent(event: MotionEvent): Boolean {
    eventDispatcher?.let { jSPointerDispatcher?.handleMotionEvent(event, it, true) }
    return super.onHoverEvent(event)
  }

  override fun onHoverEvent(event: MotionEvent): Boolean {
    eventDispatcher?.let { jSPointerDispatcher?.handleMotionEvent(event, it, false) }
    return super.onHoverEvent(event)
  }

  override fun onChildStartedNativeGesture(childView: View?, ev: MotionEvent) {
    eventDispatcher?.let { eventDispatcher ->
      jSTouchDispatcher.onChildStartedNativeGesture(ev, eventDispatcher)
      jSPointerDispatcher?.onChildStartedNativeGesture(childView, ev, eventDispatcher)
    }
  }

  override fun onChildEndedNativeGesture(childView: View, ev: MotionEvent) {
    eventDispatcher?.let { jSTouchDispatcher.onChildEndedNativeGesture(ev, it) }
    jSPointerDispatcher?.onChildEndedNativeGesture()
  }
}
