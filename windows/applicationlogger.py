import psutil
from datetime import datetime
import win32gui
import win32process
import time
from pygetwindow import getWindowsWithTitle
import json
import re
from ctypes import Structure, windll, c_uint, c_ulong, sizeof, byref

BROWSERS = ["Chrome","Firefox", "Edge",
            "Opera", "Brave",  "chrome",
            "firefox", "edge", "opera",
            "brave" ]
          
IDLE_THRESHOLD = 300  # 5 minutes


#replicating the C struct in python
class LASTINPUTINFO(Structure):
    _fields_ = [
        ('cbSize', c_uint),
        ('dwTime', c_ulong),
    ]
"""
amount of times since last user input
"""
def get_idle_time():
    lii = LASTINPUTINFO()
    lii.cbSize = sizeof(LASTINPUTINFO)

    # Calls the Windows API to get the time of last input
    windll.user32.GetLastInputInfo(byref(lii))

    #subtracts total_time from time since last idle input
    milliseconds = windll.kernel32.GetTickCount() - lii.dwTime
    return milliseconds / 1000.0  # Return idle time in seconds


    
def track_webpage():
    # active_window = win32gui.GetForegroundWindow()
    # window_title = win32gui.GetWindowText(active_window)

    # print(f"Webpage title: {window_title}")#debuggin remove
    # webpage = re.sub(r" - (Chrome|Opera|Firefox|Edge|Brave)$", "", window_title)
    # #debugging
    # print(f"Modified title: {webpage}")#debugging remove
    # return webpage
    hwnd = win32gui.GetForegroundWindow()  # Get active window handle
    window_title = win32gui.GetWindowText(hwnd)  # Get the window title
    
    # Regex to extract domain from window title
    match = re.search(r' - ([\w.-]+\.[a-z]{2,}) - (Google Chrome|Mozilla Firefox|Edge|Brave|Opera)', window_title)
    
    if match:
        return match.group(1)  # Return the domain part
    
    return "DOMAIN NOT FOUND"



def get_active_application():

    active_window = win32gui.GetForegroundWindow()
    _, pid = win32process.GetWindowThreadProcessId(active_window)

    try:
        process = psutil.Process(pid)
        process_name =  process.name()
        application_name =  re.sub (r"\.exe$", "", process_name)
        
        if application_name in BROWSERS:
            webpage_name = track_webpage()
            return webpage_name

        return application_name

    except psutil.NoSuchProcess as e:
        return None

    
"""
    Function to log the active application
"""
def activity_logger():
    activity_log = []
    last_active = None
    active_start = None
    idle_start = None


    while True:
        active_window = get_active_application()
        idle_time = get_idle_time()
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # If the user is idle 
        if idle_time > IDLE_THRESHOLD:
            if idle_start is None:
                idle_start = timestamp
        
        #if the user is active
        else:
            #if the user was idle adding the idle time to the log
            if idle_start is not None:
                activity_log.append({
                    "event": "idle",
                    "start": idle_start,
                    "end": timestamp
                })
                idle_start = None
            #if the user is active and the active window has changed
            if active_window != last_active:
                if last_active is not None:
                    activity_log.append({
                        "event": "active",
                        "application": last_active,
                        "duration": (datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S") - datetime.strptime(active_start, "%Y-%m-%d %H:%M:%S")).total_seconds()
                    })
                last_active = active_window
                active_start = timestamp





if __name__ == "__main__":
    time.sleep(2)
    activity_logger()
