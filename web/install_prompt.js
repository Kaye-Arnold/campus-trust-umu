// Small, dependency-free bridge for the browser's install prompt.
(function () {
  let deferredPrompt = null;
  window.addEventListener('beforeinstallprompt', function (event) {
    event.preventDefault();
    deferredPrompt = event;
    window.dispatchEvent(new Event('campustrust-install-available'));
  });
  window.campusTrustCanInstall = function () { return deferredPrompt !== null; };
  window.campusTrustInstall = async function () {
    if (!deferredPrompt) return false;
    deferredPrompt.prompt();
    const choice = await deferredPrompt.userChoice;
    deferredPrompt = null;
    return choice.outcome === 'accepted';
  };
  window.addEventListener('appinstalled', function () { deferredPrompt = null; });
})();
