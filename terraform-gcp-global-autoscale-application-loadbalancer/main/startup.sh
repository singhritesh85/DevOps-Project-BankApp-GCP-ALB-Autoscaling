#!/bin/bash
/usr/sbin/useradd -s /bin/bash -m ritesh;
mkdir /home/ritesh/.ssh;
chmod -R 700 /home/ritesh;
echo "ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ritesh@DESKTOP-0XXXXXX" >> /home/ritesh/.ssh/authorized_keys;
chmod 600 /home/ritesh/.ssh/authorized_keys;
chown ritesh:ritesh /home/ritesh/.ssh -R;
echo "ritesh  ALL=(ALL)  NOPASSWD:ALL" > /etc/sudoers.d/ritesh;
chmod 440 /etc/sudoers.d/ritesh;

#################################################### Installation of Required Packages ##################################################################

yum install -y kubectl google-cloud-cli-gke-gcloud-auth-plugin vim zip unzip wget git java-17*

####################################################### Installation of GitLab Runner ###################################################################

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
yum install -y gitlab-runner
###gitlab-runner register            ### Run Manually
###systemctl start gitlab-runner     ### Run Manually
###systemctl enable gitlab-runner    ### Run Manually
###systemctl status gitlab-runner    ### Run Manually

#################################################### Required configuration and Packages ################################################################

yum config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io && systemctl start docker && systemctl enable docker
chown gitlab-runner:gitlab-runner /var/run/docker.sock
cd /opt/ && wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz
tar -xvf apache-maven-3.9.11-bin.tar.gz
mv /opt/apache-maven-3.9.11 /opt/apache-maven
cd /opt && wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip
rm -f sonar-scanner-cli-4.8.0.2856-linux.zip
mv /opt/sonar-scanner-4.8.0.2856-linux/ /opt/sonar-scanner
cd /opt && wget https://nodejs.org/dist/v16.0.0/node-v16.0.0-linux-x64.tar.gz
tar -xvf node-v16.0.0-linux-x64.tar.gz
rm -f node-v16.0.0-linux-x64.tar.gz
mv /opt/node-v16.0.0-linux-x64 /opt/node-v16.0.0
cd /opt && wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip
unzip dependency-check-8.4.0-release.zip
rm -f dependency-check-8.4.0-release.zip
chown -R gitlab-runner:gitlab-runner /opt/dependency-check
cd /opt && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.38.3
echo JAVA_HOME="/usr/lib/jvm/java-17-openjdk-17.0.16.0.8-2.el8.x86_64" >> /home/gitlab-runner/.bashrc
echo PATH="$PATH:$JAVA_HOME/bin:/opt/apache-maven/bin:/opt/node-v16.0.0/bin:/opt/dependency-check/bin" >> /home/gitlab-runner/.bashrc
echo "gitlab-runner  ALL=(ALL)  NOPASSWD:ALL" >> /etc/sudoers

#################################################### Installation of Helm ###############################################################################

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 --output ~/get_helm.sh
chmod 700 ~/get_helm.sh
~/get_helm.sh

#reboot

helm version
kubectl version

##################################################### Installation Google-Cloud-Ops-Agent ###############################################################

curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
systemctl status google-cloud-ops-agent

##################################################### Installation of Python 3.9 ########################################################################

yum install -y python3.9
ln -s /usr/bin/python3.9 /usr/bin/python

##################################################### Installation of Packer ############################################################################

cd /opt/ && wget https://releases.hashicorp.com/packer/1.13.1/packer_1.13.1_linux_amd64.zip
unzip packer_1.13.1_linux_amd64.zip
rm -f packer_1.13.1_linux_amd64.zip
/opt/packer --version
