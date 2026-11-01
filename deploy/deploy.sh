#!/usr/bin/env bash
set -euo pipefail

TOMCAT_HOME=/opt/tomcat

mvn clean package

sudo systemctl stop tomcat
sudo rm -rf "$TOMCAT_HOME/webapps/ROOT" "$TOMCAT_HOME/webapps/ROOT.war"
sudo cp target/ROOT.war "$TOMCAT_HOME/webapps/ROOT.war"
sudo chown tomcat:tomcat "$TOMCAT_HOME/webapps/ROOT.war"
sudo systemctl start tomcat

echo "Deployed. Check: curl -I http://localhost:8080/employees"