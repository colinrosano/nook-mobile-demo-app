(function (d, w, o, k, h, a) {
    w[o] = w[o] || function () { w[o][k].push(a.call(arguments)); };
    w[o][k] = w[o][k] || [];
    var dnt = "{{doNotTrack}}" === "true";
    var hw = "{{hideWebWidget}" === "true";
    var l = '{{events}}'.split(',');
    var api;
    var c = d.createElement("style");
    c.innerHTML = "{{css}}";
    function hide() {
        if (api) {
            api.hideDialog();
            api.hideDoNotSell();
            api.hideDrawer();
            api.showWidget();
        }
    }
    function s(n) {
        if (n === "onInitialized") {
            var node = d.querySelector('script[src*="osano.com/{{customerId}}/{{configId}}/osano.js"]');
            if (node) {
                api = w[o].cm;
                if (node.nonce) {
                    c.setAttribute('nonce', node.nonce);
                }
                d.head.appendChild(c);
            }
        }
        if (api) {
            switch(n){
                case "onUiChanged": {
                    var e = arguments[1];
                    var b = arguments[2];
                    if (!hw && b === "show") {
                        switch(e) {
                            case "dialog":
                            case "doNotSell":
                            case "drawer": {
                                setTimeout(hide, 0);
                                break;
                            }
                        }
                    }
                }
            }
            h.postMessage(JSON.stringify({
                event: n,
                data: a.call(arguments, 1),
            }));
        }
    }
    for (var i = 0; i < l.length; i++) {
        w[o](l[i],s.bind(null, l[i]));
    }
    try {
        var p = JSON.parse('{{params}}');
        for (var i = 0; i < p.length; i++) {
            w[o][k].push(p[i].slice());
        }
    } catch {}
})(document, window, 'Osano', 'data', window.webkit.messageHandlers['{{handlerName}}'], Array.prototype.slice);
