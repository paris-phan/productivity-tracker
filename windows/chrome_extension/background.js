let activeTabId = null;
let activeStartTime = null;
let urlTracker = {};

chrome.tabs.onActivated.addListener((activeInfo) => {
    trackTime();

    // Update active tab
    activeTabId = activeInfo.tabId;
    activeStartTime = Date.now();

    // Get the URL of the newly activated tab
    chrome.tabs.get(activeTabId, (tab) => {
        if (tab && tab.url) {
            console.log("Switched to:", tab.url);
        }
    });
});

// Detect when tab is updated (like navigation)
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (tabId === activeTabId && changeInfo.url) {
        trackTime();
        activeStartTime = Date.now();
        console.log("Navigated to:", changeInfo.url);
    }
});

// Track when the tab is closed
chrome.tabs.onRemoved.addListener((tabId) => {
    if (tabId === activeTabId) {
        trackTime();
        activeTabId = null;
    }
});

// Track when the window is blurred (user switches apps)
chrome.windows.onFocusChanged.addListener((windowId) => {
    if (windowId === chrome.windows.WINDOW_ID_NONE) {
        trackTime();
        activeTabId = null;
    }
});

// Calculate time spent and send to server
function trackTime() {
    if (activeTabId && activeStartTime) {
        const timeSpent = Date.now() - activeStartTime;

        chrome.tabs.get(activeTabId, (tab) => {
            if (tab && tab.url) {
                urlTracker[tab.url] = (urlTracker[tab.url] || 0) + timeSpent;
                
                // Send data to server
                fetch("https://your-server.com/api/track-time", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        url: tab.url,
                        timeSpent: timeSpent
                    })
                })
                .then(() => console.log(`Sent ${timeSpent} ms for ${tab.url}`))
                .catch(err => console.error("Failed to send data", err));
            }
        });
    }
}
