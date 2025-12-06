function set(msg) {
    document.getElementById("status").innerText = msg;
}

(async function init() {
    let [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    document.getElementById("video_url").value = tab.url;
})();

// ============================================
// YouTube下载：使用页面URL（保持原有逻辑）
// ============================================
document.getElementById("btn_youtube").onclick = () => {
    startYouTubeDownload();
};

function startYouTubeDownload() {
    let url = document.getElementById("video_url").value;

    if (!url) {
        set("URL not found.");
        return;
    }

    let name = "video_" + Date.now();

    let payload = {
        type: "download",
        payload: {
            action: "download_youtube",
            url: url,
            referer: url,
            save_name: name
        }
    };

    chrome.runtime.sendMessage(payload, resp => {
        if (resp && resp.ok) {
            set("Download started…");
        } else {
            set("Failed to talk to native host.");
        }
    });
}

// ============================================
// M3U8下载：优先使用自动捕获的M3U8 URL
// ============================================
document.getElementById("btn_m3u8").onclick = async () => {
    await startM3U8Download();
};

async function startM3U8Download() {
    let pageUrl = document.getElementById("video_url").value;

    if (!pageUrl) {
        set("URL not found.");
        return;
    }

    // 获取当前标签页
    let [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

    // 从background获取自动捕获的M3U8 URL
    chrome.runtime.sendMessage({ type: "getM3U8", tabId: tab.id }, (response) => {
        let downloadUrl = pageUrl;  // 默认使用页面URL

        // 如果捕获到M3U8 URL，优先使用它
        if (response && response.m3u8) {
            downloadUrl = response.m3u8;
            set("Using captured M3U8...");
            console.log("[M3U8 Download] Using captured URL:", downloadUrl);
        } else {
            set("No M3U8 captured, using page URL...");
            console.log("[M3U8 Download] No M3U8 captured, using page URL");
        }

        let name = "video_" + Date.now();

        let payload = {
            type: "download",
            payload: {
                action: "download_m3u8",
                url: downloadUrl,
                referer: pageUrl,
                save_name: name
            }
        };

        chrome.runtime.sendMessage(payload, resp => {
            if (resp && resp.ok) {
                set("Download started…");
            } else {
                set("Failed to talk to native host.");
            }
        });
    });
}

// ============================================
// 接收来自 native_host 的回执
// ============================================
chrome.runtime.onMessage.addListener(msg => {
    if (msg.type === "native_response") {
        let info = msg.data;
        set(JSON.stringify(info, null, 2));
    }
});
