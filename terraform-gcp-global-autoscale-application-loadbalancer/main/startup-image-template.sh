#!/bin/bash
/usr/sbin/useradd -s /bin/bash -m ritesh;
mkdir /home/ritesh/.ssh;
chmod -R 700 /home/ritesh;
echo "ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ritesh@DESKTOP-0XXXXXX" >> /home/ritesh/.ssh/authorized_keys;
chmod 600 /home/ritesh/.ssh/authorized_keys;
chown ritesh:ritesh /home/ritesh/.ssh -R;
echo "ritesh  ALL=(ALL)  NOPASSWD:ALL" > /etc/sudoers.d/ritesh;
chmod 440 /etc/sudoers.d/ritesh;

#################################################### Installation of Required Packages ##################################################################

yum install -y google-cloud-cli-gke-gcloud-auth-plugin vim zip unzip wget git java-17*
echo JAVA_HOME="/usr/lib/jvm/java-17-openjdk-17.0.15.0.6-2.el8.x86_64" >> /etc/profile
echo PATH="$PATH:$JAVA_HOME/bin" >> /etc/profile

##################################################### Installation Google-Cloud-Ops-Agent ###############################################################

curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
systemctl status google-cloud-ops-agent

##################################################### Assign file system and mount to a directory #######################################################

mkdir /dexter;
mkfs.xfs /dev/sdb;
echo "/dev/sdb  /dexter  xfs  defaults 0 0" >> /etc/fstab;
mount -a;

#################################################### Create Linux Service to Run Java Based BankApp #####################################################

cat > /opt/bankapp-shell-script.sh <<BANKAPP
#!/bin/bash

BANKAPP=`ps -ef|grep "java -jar /opt/bankapp/bankapp.jar"|grep -v "color=auto"|awk '{print $2}'`
echo $BANKAPP
kill -9 $BANKAPP
nohup java -jar /opt/bankapp/bankapp.jar >/dev/null 2>&1 &
BANKAPP

chmod +x /opt/bankapp-shell-script.sh
cp /opt/bankapp-shell-script.sh /usr/local/bin/

cat > /etc/systemd/system/bankapp.service <<END_FOR_SCRIPT
[Unit]
Description=bankapp service
After=network.target

[Service]
Type=forking
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/lib/jvm/java-17-openjdk-17.0.16.0.8-2.el8.x86_64/bin:/usr/local/bin"
ExecStart=/usr/local/bin/bankapp-shell-script.sh start
ExecStop=/usr/local/bin/bankapp-shell-script.sh stop
User=root
Restart=on-failure

[Install]
WantedBy=multi-user.target
END_FOR_SCRIPT

systemctl daemon-reload
systemctl enable bankapp
systemctl start bankapp
systemctl status bankapp
