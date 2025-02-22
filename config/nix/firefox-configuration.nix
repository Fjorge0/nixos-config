## Privacy Settings for Firefox
# https://github.com/arkenfox/user.js/blob/master/user.js

{ config, ... }:

{
  programs.firefox.preferences = {
    # Disable about:config warning
    "browser.aboutConfig.showWarning" = false;

    # Startup and New Tab pages
    "browser.startup.page" = 3;
    "browser.startup.homepage" = "about:blank";
    "browser.newtabpage.enabled" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.default.sites" = "";
    
    # Geolocation settings
    "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
    "geo.provider.use_gpsd" = false;
    "geo.provider.use_geoclue" = false;

    # Language
    "intl.accept_languages" = "en-UK, en";

    # Addons page
    "extensions.getAddons.showPane" = false;
    "extensions.htmlaboutaddons.recommendations.enabled" = false;
    "browser.discovery.enabled" = false;

    # Telemetry
    "datareporting.policy.dataSubmissionEnabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.server" = "data:,";
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.coverage.opt-out" = true;
    "toolkit.coverage.opt-out" = true;
    "toolkit.coverage.endpoint.base" = "";
    "browser.ping-centre.telemetry" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;

    # Studies
    "app.shield.optoutstudies.enabled" = false;
    "app.normandy.enabled"= false;
    "app.normandy.api_url" = "";

    # Crash reports
    "breakpad.reportURL" = "";
    "browser.tabs.crashReporting.sendReport" = false;
    "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

    # Safe browsing
    "browser.safebrowing.downloads.remote.enabled" = false;

    # Block implicit outbound traffic
    "network.prefetch-next" = false;
    "network.dns.disablePrefetch" = true;
    "network.predictor.enabled" = false;
    "network.predictor.enable-prefetch" = false;
    "network.http.speculative-parallel-limit" = 0;
    "browser.places.speculativeConnect.enabled" = false;

    # DNS / DoH / Proxy / SOCKS
    "network.proxy.socks_remote_dns" = true;
    "network.file.disable_unc_paths" = true;
    "network.gio.supported-protocols" = "";

    # Suggestions
    "browser.fixup.alternate.enabled" = false;
    "browser.search.suggest.enabled" = false;
    "browser.urlbar.suggest.searches" = false;
    "browser.urlbar.speculativeConnect.enabled" = false;
    "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0;
    "browser.urlbar.suggest.quicksuggest.notsponsored" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;

    # Passwords
    "singon.autofillForms" = false;
    "signon.formlessCapture.enabled" = false;
    "network.auth.subresource-http-auth-allow" = 1;

    # HTTPS
    "security.ssl.require_safe_negotiation" = true;
    "security.tls.enable_0rtt_data" = false;
    "security.OCSP.enabled" = 1;
    "security.OCSP.require" = false;
    "security.family_safety.mode" = 0;
    "security.cert_pinning.enforcement_level" = 2;
    "security.remote_settings.crlite_filters.enabled" = true;
    "security.pki.crlite_mode" = 2;
    "dom.security.https_only_mode" = true;
    "dom.security.https_only_mode_send_http_background_request" = false;
    "security.ssl.treat_unsafe_negotiation_as_broken" = true;
    "browser.xul.error_pages.expert_bad_cert" = true;

    # Referers
    "network.http.referer.XOriginTrimmingPolicy" = 2;

    # Plugins
    "media.perrconnection.ice.proxy_only_if_behind_proxy" = true;
    "media.peerconnection.ice.default_address_only" = true;

    # DOM
    "dom.disable_window_move_resize" = true;

    # MISC
    "#accessibility.force_disabled" = 1;
    "browser.helperApps.deleteTempFileOnExit" = true;
    "browser.uitour.enabled" = false;
    "devtools.debugger.remote-enabled" = false;
    "permissions.manager.defaultsUrl" = "";
    "webchannel.allowObject.urlWhiteList" = "";
    "network.IDN_show_punycode" = true;
    "pdfjs.disabled" = false;
    "pdfjs.enableeScripting" = false;
    "permissions.delegation.enabled" = false;
    "browser.tabs.searchclipboardfor.middleclick" = false;

    # Downloads
    "browser.download.useDownloadDir" = false;
    "browser.download.alwaysOpenPanel" = false;
    "browser.download.manager.addToRecentDocs" = false;
    "browser.download.always_ask_before_handling_new_types" = true;

    # Extensions
    "extensions.enabledScopes" = 5;
    "extensions.autoDisableScopes" = 15;
    "extensions.postDownloadThirdPartyPrompt" = false;

    # ETP
    "browser.contentblocking.category" = "strict";
    "privacy.partition.serviceWorkers" = true;
    "privacy.partition.always_partition_third_party_non_cookie_storage" = true;
    "privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage" = false;

    # Shutdown
    "privacy.clearOnShutdown.cache" = true;
    "privacy.clearOnShutdown.downloads" = true;
    "privacy.clearOnShutdown.formdata" = true;
    "privacy.clearOnShutdown.history" = false;
    "privacy.clearOnShutdown.sessions" = false;
    #"privacy.clearOnShutdown.cookies" = true;
    "privacy.clearOnShutdown.offlineApps" = true;
    "privacy.cpd.cache" = true;
    "privacy.cpd.formdata" = true;
    "privacy.cpd.history" = true;
    "privacy.cpd.sessions" = true;
    "privacy.cpd.offlineApps" = false;
    "privacy.cpd.cookies" = false;
    "privacy.sanatize.timeSpam" = 0;

    # Resist fingerprinting
    "privacy.resistFingerprinting" = true;
    "privacy.resistFingerprinting.block_mozAddonManager" = true;
    "browser.link.open_newwindow" = 3;
    "browser.link.open_newwindow.restriction" = 0;

    # Pocket
    "extensions.pocket.enabled" = false;
    "browser.pocket.api" = "";
    "browser.pocket.oAuthConsumerKey" = "";
    "browser.pocket.site" = "";

    # Other
    "extensions.blocklist.enabled" = true;
    "network.https.referer.spoofSource" = false;
    "security.dialog_enable_delay" = 1000;
    "privacy.firstparty.isolate" = false;
    "extensions.webcompat.enable_shims" = true;
    "security.tls.version.enable-deprecated" = false;
    "extensions.webcompat-reporter.enabled" = false;
    "extensions.quarantinedDomains.enabled" = true;
  };
}

# vim: tabstop=2 shiftwidth=2 expandtab
