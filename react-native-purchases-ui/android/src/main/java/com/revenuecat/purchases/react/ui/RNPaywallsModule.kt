package com.revenuecat.purchases.react.ui

import android.util.Log
import androidx.fragment.app.FragmentActivity
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.revenuecat.purchases.hybridcommon.ui.PaywallResultListener
import com.revenuecat.purchases.hybridcommon.ui.presentPaywallFromFragment

internal class RNPaywallsModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {
    companion object {
        const val NAME = "RNPaywalls"
    }

    private val currentActivityFragment: FragmentActivity?
        get() {
            return when (val currentActivity = currentActivity) {
                is FragmentActivity -> currentActivity
                else -> {
                    Log.e(NAME, "RevenueCat paywalls require application to use a FragmentActivity")
                    null
                }
            }
        }

    override fun getName(): String {
        return NAME
    }

    @ReactMethod
    fun presentPaywall(
        options: ReadableMap,
        promise: Promise
    ) {
        val hashMap = options.toHashMap()
        val offeringIdentifier = hashMap["offeringIdentifier"] as String?
        val displayCloseButton = hashMap["displayCloseButton"] as Boolean?

        presentPaywall(
            null,
            offeringIdentifier,
            displayCloseButton,
            promise
        )
    }

    @ReactMethod
    fun presentPaywallIfNeeded(
        options: ReadableMap,
        promise: Promise
    ) {
        val hashMap = options.toHashMap()
        val requiredEntitlementIdentifier = hashMap["requiredEntitlementIdentifier"] as String?
        val offeringIdentifier = hashMap["offeringIdentifier"] as String?
        val displayCloseButton = hashMap["displayCloseButton"] as Boolean?

        presentPaywall(
            requiredEntitlementIdentifier,
            offeringIdentifier,
            displayCloseButton,
            promise
        )
    }

    private fun presentPaywall(
        requiredEntitlementIdentifier: String?,
        offeringIdentifier: String?,
        displayCloseButton: Boolean?,
        promise: Promise
    ) {
        val fragment = currentActivityFragment ?: return

        // TODO wire offeringIdentifier
        presentPaywallFromFragment(
            fragment = fragment,
            requiredEntitlementIdentifier = requiredEntitlementIdentifier,
            shouldDisplayDismissButton = displayCloseButton,
            paywallResultListener = object : PaywallResultListener {
                override fun onPaywallResult(paywallResult: String) {
                    promise.resolve(paywallResult)
                }
            }
        )
    }
}