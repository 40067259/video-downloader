// 全局Promise rejection处理
window.addEventListener('unhandledrejection', event => {
    console.log('Popup handled promise rejection:', event.reason);
    event.preventDefault();
});

function set(msg) {
    document.getElementById("status").innerText = msg;
}

(async function init() {
    try {
        let [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
        document.getElementById("video_url").value = tab.url;
    } catch (error) {
        console.error("Init error:", error);
    }
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
        if (chrome.runtime.lastError) {
            set("Failed to connect: " + chrome.runtime.lastError.message);
            return;
        }
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
        if (chrome.runtime.lastError) {
            set("Failed to connect: " + chrome.runtime.lastError.message);
            return;
        }

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
            if (chrome.runtime.lastError) {
                set("Failed to connect: " + chrome.runtime.lastError.message);
                return;
            }
            if (resp && resp.ok) {
                set("Download started…");
            } else {
                set("Failed to talk to native host.");
            }
        });
    });
}

// ============================================
// Progress Bar Functions
// ============================================

// 显示/隐藏进度条
function showProgress(show) {
    document.getElementById("progress_container").style.display = show ? "block" : "none";
}

// 更新进度条
function updateProgress(data) {
    if (data.percent !== undefined) {
        const percent = Math.min(100, Math.max(0, data.percent));
        document.getElementById("progress_bar").style.width = percent + "%";
        document.getElementById("progress_percent").textContent = percent.toFixed(1) + "%";
    }

    if (data.speed) {
        document.getElementById("progress_speed").textContent = data.speed;
    }

    if (data.eta) {
        document.getElementById("progress_eta").textContent = "ETA: " + data.eta;
    }

    if (data.filename) {
        document.getElementById("progress_filename").textContent = data.filename;
    }
}

// 重置进度条
function resetProgress() {
    document.getElementById("progress_bar").style.width = "0%";
    document.getElementById("progress_percent").textContent = "0%";
    document.getElementById("progress_speed").textContent = "";
    document.getElementById("progress_eta").textContent = "";
    document.getElementById("progress_filename").textContent = "";
}

// ============================================
// 接收来自 native_host 的回执和进度
// ============================================
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
    if (msg.type === "native_response") {
        let info = msg.data;

        // 检查是否是最终结果
        if (info.status === "done") {
            showProgress(false);
            let folder = "/home/zhangf/workplace/download_plugin/linux_package";
            let message = `Congratulations!\n\n"${info.file}" is saved in:\n${folder}`;
            set(message);
        } else if (info.status === "error") {
            showProgress(false);
            let errorMsg = info.msg || "Unknown error";
            let message = `Download failed!\n\nError: ${errorMsg}`;
            if (info.exit_code) {
                message += `\nExit code: ${info.exit_code}`;
            }
            set(message);
        }
    }

    // 处理进度更新
    if (msg.type === "download_progress") {
        showProgress(true);
        updateProgress(msg.data);
    }

    // 不需要响应，返回false
    return false;
});
