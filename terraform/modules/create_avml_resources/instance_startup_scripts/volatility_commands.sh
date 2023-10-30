#!/bin/bash
output=$1
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.bash.Bash > $output/$output-bash.txt
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.check_idt.Check_idt > $output/$output-checkidt.txt
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.check_syscall.Check_syscall > $output/$output-check_syscall.txt
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.elfs.Elfs > $output/$output-elfs.txt
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.lsmod.Lsmod > $output/$output-lsmod.txt
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.lsof.Lsof > $output/$output-lsof.txt
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.mountinfo.MountInfo > $output/$output-mountinfo.txt
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.proc.Maps > $output/$output-proc.txt
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.psaux.PsAux > $output/$output-psaux.txt
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.pslist.PsList > $output/$output-pslist.txt
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.pstree.PsTree > $output/$output-pstree.txt
python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.tty_check.tty_check > $output/$output-tty_check.txt
# python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q banners.Banners > $output/$output-banners.txt
# python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.check_afinfo.Check_afinfo > $output/$output-Check_afinfo.txt
# python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.check_creds.Check_creds > $output/$output-Check_creds.txt
# python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.check_modules.Check_modules > $output/$output-Check_modules.txt
# python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.envars.Envars > $output/$output-Envars.txt
# python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.envvars.Envvars > $output/$output-Envvars.txt
# python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.iomem.IOMem > $output/$output-IOMem.txt
# python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.keyboard_notifiers.Keyboard_notifiers > $output/$output-Keyboard_notifiers.txt
# python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.kmsg.Kmsg > $output/$output-Kmsg.txt
# python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.psscan.PsScan > $output/$output-PsScan.txt
# python3 volatility3/vol.py -s volatility3/volatility3/symbols/dwarf2json_profile.json -f $output.lime -q linux.sockstat.Sockstat > $output/$output-Sockstat.txt