let port = null;
let m3u8Urls = {}; // 存储每个标签页捕获的M3U8 URL {tabId: url}
let debuggerAttached = {}; // 跟踪哪些标签页已附加debugger

// ============================================
// Native Messaging (YouTube下载使用，不变)
// ============================================
function connectNative() {
    if (port) return port;

    port = chrome.runtime.connectNative("com.videodl.host");

    port.onMessage.addListener(raw => {
        console.log("Raw from native:", raw);

        let msg = raw;

        if (typeof raw === "string") {
            raw = raw.replace(/^[^({[]+/, "");
            try {
                msg = JSON.parse(raw);
            } catch (e) {
                console.error("JSON parse failed:", raw);
                return;
            }
        }

        console.log("Parsed native msg:", msg);

        chrome.runtime.sendMessage({
            type: "native_response",
            data: msg
        });
    });

    port.onDisconnect.addListener(() => {
        if (chrome.runtime.lastError) {
            console.error("Native host connection error:", chrome.runtime.lastError.message);
        } else {
            console.log("Native host disconnected");
        }
        port = null;
    });

    return port;
}

// ============================================
// M3U8 自动捕获 (仅用于M3U8下载)
// ============================================

// 检查URL是否应该附加debugger
function shouldAttachDebugger(url) {
    if (!url) return false;

    // 排除Chrome内部页面
    const excludedPrefixes = [
        'chrome://',
        'chrome-extension://',
        'about:',
        'edge://',
        'devtools://'
    ];

    return !excludedPrefixes.some(prefix => url.startsWith(prefix));
}

// 附加debugger到标签页
async function attachDebugger(tabId, url) {
    if (debuggerAttached[tabId]) {
        return; // 已经附加
    }

    // 检查是否应该附加
    if (!shouldAttachDebugger(url)) {
        return;
    }

    try {
        await chrome.debugger.attach({ tabId }, "1.3");
        await chrome.debugger.sendCommand({ tabId }, "Network.enable");
        debuggerAttached[tabId] = true;
        console.log("[M3U8 Debugger] Attached to tab:", tabId);
    } catch (error) {
        console.error("[M3U8 Debugger] Failed to attach:", error);
    }
}

// 分离debugger
async function detachDebugger(tabId) {
    if (!debuggerAttached[tabId]) return;

    try {
        await chrome.debugger.detach({ tabId });
        delete debuggerAttached[tabId];
        delete m3u8Urls[tabId];
        console.log("[M3U8 Debugger] Detached from tab:", tabId);
    } catch (error) {
        // 忽略错误（标签页可能已关闭）
    }
}

// 监听网络请求 - 捕获M3U8
chrome.debugger.onEvent.addListener((source, method, params) => {
    if (method === "Network.requestWillBeSent") {
        const url = params.request.url;

        // 检查是否是M3U8请求
        if (url.includes('.m3u8')) {
            const tabId = source.tabId;
            m3u8Urls[tabId] = url;
            console.log("[M3U8 Debugger] Captured M3U8:", url);
        }
    }
});

// 标签页激活时自动附加debugger
chrome.tabs.onActivated.addListener(async (activeInfo) => {
    const tabId = activeInfo.tabId;

    try {
        const tab = await chrome.tabs.get(tabId);

        // 只对非YouTube页面附加debugger（保护YouTube下载）
        if (tab.url && !tab.url.includes('youtube.com')) {
            await attachDebugger(tabId, tab.url);
        }
    } catch (error) {
        // 忽略错误
    }
});

// 标签页更新时附加debugger（新加载的页面）
chrome.tabs.onUpdated.addListener(async (tabId, changeInfo, tab) => {
    if (changeInfo.status === 'loading' && tab.url) {
        // 只对非YouTube页面附加debugger
        if (!tab.url.includes('youtube.com')) {
            await attachDebugger(tabId, tab.url);
        }
    }
});

// 标签页关闭时清理
chrome.tabs.onRemoved.addListener((tabId) => {
    detachDebugger(tabId);
});

// debugger分离时清理
chrome.debugger.onDetach.addListener((source, reason) => {
    const tabId = source.tabId;
    delete debuggerAttached[tabId];
    console.log("[M3U8 Debugger] Debugger detached:", reason);
});

// ============================================
// 消息处理
// ============================================
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
    // 下载请求 (YouTube和M3U8都使用)
    if (msg.type === "download") {
        let p = connectNative();
        console.log("Sending to native:", msg.payload);
        p.postMessage(msg.payload);
        sendResponse({ ok: true });
        return true;
    }

    // 获取捕获的M3U8 URL (仅M3U8下载使用)
    if (msg.type === "getM3U8") {
        const url = m3u8Urls[msg.tabId] || null;
        console.log("[M3U8 Debugger] Returning M3U8 for tab", msg.tabId, ":", url);
        sendResponse({ m3u8: url });
        return true;
    }
});

console.log("[Background] Service worker loaded");
