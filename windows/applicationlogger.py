import psutil
from datetime import datetime
import win32gui
import win32process
import time
from pygetwindow import getWindowsWithTitle
import json
import re
import logging
import pyautogui
import pyperclip
from ctypes import Structure, windll, c_uint, c_ulong, sizeof, byref
import signal 
from pywinauto import Application

#list of supported chromium based browsers
BROWSERS = ["chrome", "chromium", "firefox",
            "opera", "edge", "brave"]  
BROWSER_TITLES = {
    "chrome": "Address and search bar",
    "firefox": "Search or enter address",
    "edge": "Address and search bar",
    "opera": "Address field",
    "brave": "Address and search bar",
}
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


    
def get_browser_url(browser_name):
    browser_name_cap = browser_name.capitalize()
    app = Application(backend='uia')
    app.connect(title_re=f".*{browser_name_cap}.*")
    element_name = BROWSER_TITLES[browser_name.lower()]
    dlg = app.top_window()
    url = dlg.child_window(title=element_name, control_type="Edit").get_value()
    return url 


def get_active_application():

    active_window = win32gui.GetForegroundWindow()
    _, pid = win32process.GetWindowThreadProcessId(active_window)

    if pid ==0:
        logging.warning("No active window detected (PID = 0 )")
        return None
    try:
        process = psutil.Process(pid)
        process_name =  process.name()
        application_name =  re.sub (r"\.exe$", "", process_name)
        
        logging.info(f"Active application: {application_name}")
        #if the active application is a browser
        if application_name.lower() in BROWSERS:
            #geting the active tab url
            return get_browser_url(application_name.lower())

        return application_name.lower()

    except psutil.NoSuchProcess:
        logging.warning(f"Process with PID {pid} not found")
        return None
    except Exception as e:
        logging.error(f"Error:{e}")
        return None
 
    
"""
    Function to log the active application
"""
def activity_logger():
    activity_log = []
    last_active = None
    active_start = None
    idle_start = None

    start_time = time.time()
    run_duration = 60 #loop runs for 15 seconds
    while True:
    
        active_window = get_active_application()
        logging.warning(f"Active window: {active_window}")
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
                    "application": last_active,
                    "start": idle_start,
                    "end": timestamp, 
                    "duration": (datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S") - datetime.strptime(idle_start, "%Y-%m-%d %H:%M:%S")).total_seconds()
                })
                idle_start = None
            #if the user is active and the active window has changed
            if active_window != last_active:
                if last_active is not None:
                    activity_log.append({
                        "event": "active",
                        "application": last_active,
                        "start": active_start,
                        "end": timestamp,
                        "duration": (datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S") - datetime.strptime(active_start, "%Y-%m-%d %H:%M:%S")).total_seconds()
                    })
                last_active = active_window
                active_start = timestamp

        time.sleep(1)        


        ###For now only running the loop x-amount of time ####
        if time.time() - start_time > run_duration :
            print(activity_log)
            break
        


if __name__ == "__main__":
    activity_logger()
