#!/usr/bin/python3
from subprocess import Popen, PIPE
from re import findall
import requests
import time
#####################################################################################################################################################################
class NSLookup:
    def __init__(self, domains):
        self.domains = domains
        self.canonical = r"\s+canonical\s+name\s+=\s+(.*)\s+"
        self.address = r"Address:\s+(\d+.\d+.\d+.\d+)\s+"

    def examine(self):
        for d in self.domains:
            data = {'domain': d, 'names': [], 'ips': []}
            cmd = ["nslookup",  d]
            out = Popen(cmd, stdout=PIPE).communicate()[0].decode()
            server_names = findall(self.canonical, out)
            server_ips = findall(self.address, out)
            data['names'] = [name for name in server_names]
            data['ips'] = [ip for ip in server_ips]
            yield data
#####################################################################################################################################################################
def nslookup(domain_list):
    for test in NSLookup(domain_list).examine():
        print(test)
    return;
#####################################################################################################################################################################
def run_bash_commands(cmd_list):
    import subprocess
    import os
    for cmd in cmd_list:
        print("Current command is '"+cmd+"'")
        try:
            if cmd.startswith("./"):
                subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
            else:
                output = subprocess.run(cmd.split(), cwd = os.getcwd(), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            print(f"Command output was: {output.stdout}")
            print(f"Command error was: {output.stderr}")
        except FileNotFoundError as e:
            print(f"Error for cmd: {cmd} was:{e}")
        
        # Modify bash history: This command below modifies the history with the cmd input rather than printing the result
        subprocess.Popen(['bash', '-ic', 'set -o history; history -s "$1"', '_', cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        process         =   subprocess.Popen(['bash', '-ic', 'set -o history; history -s "$1"', '_', cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr  =   process.communicate()
    return;
#####################################################################################################################################################################
def modify_file(file_name, file_content):
    from os.path import exists
    import subprocess
    if exists(file_name) == False:
        print("Creating "+file_name)
        with open(file_name, "w") as file:
            file.write(file_content)
        cmd = "chmod +x "+file_name
        process = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()
    else:
        print(file_name+" already exists")
    return;
#####################################################################################################################################################################
def connect_domain(domains_to_connect_list):
    for domain in domains_to_connect_list:
        r = requests.get(domain)
        print("Result for domain: "+domain+" was: "+str(r))
    return;
#####################################################################################################################################################################
if __name__ == "__main__":

    domain_list = [
        'www.unc.edu', 'www.umb.edu', 'www.harvard.edu',
        'www.cornell.edu', 'www.psu.edu', 'www.cam.ac.uk',
        'www.umass.edu', 'www.mit.edu', 'www.unimelb.edu.au'
    ]
    malicious_file_name       =   "malicious_script.sh"
    curl_file_name            =   "bash_curl.sh" 
    malicious_file_content    =   "#!/bin/bash"+"\n"+"set -e"+"\n"+'if ! type -- "$1" &> /dev/null; then'+"\n"+'       set -- /bin/nc -l 10514 "$@"'+"\n"+"fi"+"\n"+'echo "->>>>>> (Executing '"$@"') <<<<<<-"'+"\n"+'exec "$@"'
    curl_file_content         =   "#!/bin/bash"+"\n"+"set -e"+"\n"+'if ! type -- "$1" &> /dev/null; then'+"\n"+'       set -- /usr/bin/watch -n 1 /usr/bin/curl -s ifconfig.co "$@"'+"\n"+"fi"+"\n"+'echo "->>>>>> (Executing '"$@"') <<<<<<-"'+"\n"+'exec "$@"'
    # Runs without "&" and shows curl command.
    cmd_list_start            =   [ "apt-get install -y netcat", "./"+malicious_file_name, "rm "+malicious_file_name, "ls -la" ] 
    domains_to_connect_list = [ "https://www.dn.se", "https://www.wikipedia.org" ]
    modify_file(malicious_file_name, malicious_file_content)
    #modify_file(curl_file_name, curl_file_content)
    
    run_bash_commands(cmd_list_start)
    
    round=0
    try:
        while True:
            round +=  1
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    
    print(f"Script ran for: {round} seconds")