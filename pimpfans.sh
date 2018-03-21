#!/bin/bash
#
# Quick and dirty patch to control AMD fans.
#
# Usage:  pimp-fans [speed]
#
#    If no speed is provided, will simply set the fans to 90%.
#
# by Anjin for https://getpimp.org
#

#
# Fan Speed, 228 = 90% (256*.90)
export FANSPEED=${1:-228}

echo "Setting fanspeed to $FANSPEED for AMD GPUs"

export AMDGPUS="`lspci | grep VGA | grep AMD | gawk '{printf "%s ",$1}'`"

ls -l /sys/class/drm | gawk '
        BEGIN {
                GPULIST = ENVIRON["AMDGPUS"] ;
                split(GPULIST,gpus," ") ;
                SPEED = ENVIRON["FANSPEED"]
                }
        {
                for(idx in gpus){
                        if(index($NF,gpus[idx])){
                                cnt = split($NF,tary,"/");
                                hcnt = split(tary[cnt],hary,"-");
                                if(hcnt==1 && index(tary[cnt],"card")){
                                        outdir = sprintf("/sys/class/drm/%s/device/hwmon",$9);
                                        syscmd = sprintf("ls %s",outdir);
                                        syscmd | getline tdir ; close(syscmd) ;
                                        Outdir = sprintf("%s/%s",outdir,tdir) ;
                                        PwmEnable = sprintf("%s/pwm1_enable",Outdir);
                                        print "1" >> PwmEnable ; close(PwmEnable) ;
                                        printf "card %s # echo 1 >> %s\n",gpus[idx],PwmEnable  ;
                                        PwmSpeed = sprintf("%s/pwm1",Outdir);
                                        print SPEED >> PwmSpeed ; close(PwmSpeed) ;
                                        printf "card %s # echo %s >> %s\n",gpus[idx],SPEED,PwmSpeed ;
                                        }
                                }
                        }
                }'
