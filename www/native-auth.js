// ============================================================
//  native-auth.js — Capacitor native Google Sign-in bridge
//
//  When running inside the native app, Google Sign-in must use
//  the native Firebase Auth SDK via @capacitor-firebase/authentication.
//  This replaces signInWithPopup / signInWithRedirect which are blocked
//  in embedded WebViews by Google's policy.
//
//  The plugin fires onAuthStateChanged on the web Firebase SDK automatically
//  once native sign-in completes, so the rest of the app works unchanged.
// ============================================================

(function () {
  'use strict';

  // Only activate in the native Capacitor shell
  if (!window.Capacitor || !window.Capacitor.isNativePlatform()) return;

  const FA = window.Capacitor.Plugins.FirebaseAuthentication;
  if (!FA) {
    console.warn('[native-auth] FirebaseAuthentication plugin not found — native sign-in disabled');
    return;
  }

  // Patch the global signInGoogle function once the page is fully loaded
  document.addEventListener('DOMContentLoaded', () => {
    // Wait a tick so community.js has defined signInGoogle
    setTimeout(() => {
      if (typeof window.signInGoogle === 'function') {
        window.signInGoogle = async function () {
          try {
            await FA.signInWithGoogle();
            // onAuthStateChanged fires automatically — nothing else needed
          } catch (e) {
            // user cancelled or error
            if (e.code !== 'authentication-cancelled') {
              const msg = e.message || e.code || String(e);
              if (typeof toast === 'function') toast('Google sign-in failed: ' + msg);
            }
          }
        };
        console.log('[native-auth] signInGoogle patched → native Google Sign-in active');
      }
    }, 0);
  });

})();
