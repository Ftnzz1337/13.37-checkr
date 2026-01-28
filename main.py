import os
import sys
import ctypes
import urllib.request
import zipfile
import subprocess
import shutil
import time
import webbrowser


# исходный код открыт, кому надо берите
BANNER = r"""
  ▄▄▄▄ ▄▄▄▄▄▄▄     ▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄         ▄▄                             
▄█████ ▀▀▀▀████    ▀▀▀▀████ ████████         ██                ▄▄           
   ███   ▄▄██▀       ▄▄██▀      ▄██▀   ▄████ ████▄ ▄█▀█▄ ▄████ ██ ▄█▀ ████▄ 
   ███     ███▄        ███▄    ███     ██    ██ ██ ██▄█▀ ██    ████   ██ ▀▀ 
   ███ ███████▀ ██ ███████▀    ███     ▀████ ██ ██ ▀█▄▄▄ ▀████ ██ ▀█▄ ██    
"""

def is_admin():
    try: return ctypes.windll.shell32.IsUserAnAdmin()
    except: return False

def download_and_unzip(url, folder_name):
    temp_dir = os.environ['TEMP']
    dest_folder = os.path.join(temp_dir, folder_name)
    if not os.path.exists(dest_folder):
        os.makedirs(dest_folder)
    
    zip_path = os.path.join(dest_folder, "temp.zip")
    try:
        urllib.request.urlretrieve(url, zip_path)
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(dest_folder)
        os.remove(zip_path)
        return dest_folder
    except Exception as e:
        print(f"ERROR {folder_name}: {e}")
        return None

def run_logic():
    os.system('cls' if os.name == 'nt' else 'clear')
    print(BANNER)
    
    temp_dir = os.environ['TEMP']
    
    urls = {
        "EV": "https://www.voidtools.com/Everything-1.4.1.1026.x64.zip",
        "PH": "https://github.com/processhacker/processhacker/releases/download/v2.39/processhacker-2.39-bin.zip",
        "LAV": "https://www.nirsoft.net/utils/lastactivityview.zip",
        "SBV": "https://www.nirsoft.net/utils/shellbagsview.zip"
    }

    paths = {}
    print("loading")
    
    for key, url in urls.items():
        print(f"[>] downloading...")
        paths[key] = download_and_unzip(url, f"Checker_{key}")

    exe_ev = os.path.join(paths["EV"], "Everything.exe")
    exe_ph = os.path.join(paths["PH"], "x64", "ProcessHacker.exe")
    exe_lav = os.path.join(paths["LAV"], "LastActivityView.exe")
    exe_sbv = os.path.join(paths["SBV"], "ShellBagsView.exe")

    query = "size:2263|size:5266|size:6515|size:6770|size:6778|size:7016|size:7218|size:7803|size:7891|size:9327|size:10283|size:10605|size:10958|size:11554|size:16541|size:17308|size:17339|size:18180|size:18527|size:18587|size:18734|size:19266|size:20578|size:20583|size:20639|size:20883|size:21161|size:21234|size:21664|size:22036|size:22861|size:26247|size:27546|size:27809|size:28084|size:28439|size:29304|size:29567|size:30279|size:31549|size:31607|size:34449|size:34669|size:35971|size:35993|size:38149|size:39017|size:39321|size:40142|size:42782|size:47159|size:48242|size:50828|size:51212|size:52426|size:54088|size:59381|size:62782|size:65316|size:65486|size:65765|size:66659|size:67491|size:68794|size:69757|size:72334|size:74105|size:80751|size:88896|size:95530|size:98811|size:100523|size:100799|size:101297|size:101571|size:101703|size:102297|size:102733|size:103761|size:104954|size:105623|size:105672|size:112386|size:120640|size:138417|size:143006|size:143597|size:143600|size:147329|size:147873|size:151762|size:153937|size:156722|size:156779|size:166677|size:169718|size:173698|size:183634|size:183651|size:192156|size:202720|size:257482|size:263070|size:267746|size:274865|size:300286|size:334588|size:343169|size:350629|size:409616|size:410358|size:517248|size:519731|size:532826|size:539151|size:556494|size:597406|size:636621|size:640838|size:878781|size:925493|size:1077149|size:1165063|size:1181556|size:1444714|size:1471429|size:1569093|size:1822841|size:3113569|size:3425801|size:3541075|size:3541138|size:3642292|size:3684385|size:4642998|size:5630483|size:7052171|size:7059952|size:22258750|size:25704986|size:26179274|size:26691896 *.jar"
    subprocess.Popen([exe_ev, "-search", query])
    subprocess.Popen([exe_ph], cwd=os.path.dirname(exe_ph))

    subprocess.Popen([exe_sbv], cwd=os.path.dirname(exe_sbv))

    lav_proc = subprocess.Popen([exe_lav], cwd=os.path.dirname(exe_lav))
    time.sleep(3)

    vbs_script = os.path.join(temp_dir, "auto_lav.vbs")
    with open(vbs_script, "w") as f:
        f.write(f'''
Set WshShell = WScript.CreateObject("WScript.Shell")
If WshShell.AppActivate("LastActivityView") Then
    WScript.Sleep 500
    WshShell.SendKeys "^f"
    WScript.Sleep 800
    WshShell.AppActivate "Find" 
    WScript.Sleep 400
    WshShell.SendKeys "java"
    WScript.Sleep 200
    WshShell.SendKeys "%c"
    WScript.Sleep 200
    WshShell.SendKeys "{{ENTER}}"
End If
''')
    
    subprocess.run(["cscript", "//Nologo", vbs_script])
    if os.path.exists(vbs_script):
        os.remove(vbs_script)

    print("\n" + "="*50)
    print("1 - close")
    print("2 - holy-check")
    print("="*50)

    while True:
        choice = input("select: ").strip()
        if choice == "2":
            webbrowser.open("https://mods.holyworld.me/mods/check")
        elif choice == "1":
            print("[!] cleaning up...")
            procs = ["Everything.exe", "ProcessHacker.exe", "LastActivityView.exe", "ShellBagsView.exe"]
            for p in procs:
                subprocess.run(f"taskkill /IM {p} /F /T", shell=True, stderr=subprocess.DEVNULL)
            
            time.sleep(1)
            for key in urls.keys():
                folder = os.path.join(temp_dir, f"Checker_{key}")
                if os.path.exists(folder):
                    shutil.rmtree(folder, ignore_errors=True)
            print("[+] done")
            break

if __name__ == "__main__":
    if is_admin():
        run_logic()
    else:
        ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, " ".join(sys.argv), None, 1)

