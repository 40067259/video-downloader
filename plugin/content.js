let lastM3U8 = null;

// 注入脚本来拦截网络请求
(function() {
    const script = document.createElement('script');
    script.textContent = `
        (function() {
            const originalFetch = window.fetch;
            const originalXHROpen = XMLHttpRequest.prototype.open;
            const originalXHRSend = XMLHttpRequest.prototype.send;

            // 拦截 fetch 请求
            window.fetch = function(...args) {
                const url = args[0];
                if (typeof url === 'string' && url.includes('.m3u8')) {
                    window.postMessage({
                        type: 'M3U8_DETECTED',
                        url: url,
                        source: 'fetch'
                    }, '*');
                }
                return originalFetch.apply(this, args);
            };

            // 拦截 XMLHttpRequest
            XMLHttpRequest.prototype.open = function(method, url, ...rest) {
                this._url = url;
                return originalXHROpen.apply(this, [method, url, ...rest]);
            };

            XMLHttpRequest.prototype.send = function(...args) {
                if (this._url && this._url.includes('.m3u8')) {
                    window.postMessage({
                        type: 'M3U8_DETECTED',
                        url: this._url,
                        source: 'xhr'
                    }, '*');
                }
                return originalXHRSend.apply(this, args);
            };

            console.log('[M3U8 Detector] Injection successful');
        })();
    `;
    (document.head || document.documentElement).appendChild(script);
    script.remove();
})();

// 监听来自注入脚本的消息
window.addEventListener('message', (event) => {
    if (event.source !== window) return;

    if (event.data.type === 'M3U8_DETECTED') {
        lastM3U8 = event.data.url;
        console.log('[M3U8 Detector] Captured M3U8 URL:', lastM3U8);
    }
});

// 响应popup的查询
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
    if (msg.action === "getM3U8") {
        sendResponse({ m3u8: lastM3U8 });
    }
});

console.log('[M3U8 Detector] Content script loaded');
