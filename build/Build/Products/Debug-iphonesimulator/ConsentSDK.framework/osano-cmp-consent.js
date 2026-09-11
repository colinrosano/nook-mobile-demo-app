(function (s) {
    var k = "{{storageKey}}",
    e = "{{encryptedConsent}}",
    u = "{{uuid}}";
    s.setItem(k, e);
    s.setItem(k + "_uuid", u);
})(window.localStorage);
