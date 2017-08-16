SUDO = sudo
# Uncomment if running as root
# SUDO =
TAPCONN_ROOT := /opt/tapconn
TAPCONN_SERVICE := tapconn.service
TAPCONN_ENV := tapconn.env
TAPCONN_STAP := tapconn.stap
SYSTEMD_SERVICE_DIR := /usr/lib/systemd/system/
SYSTEMD_SERVICE := $(SYSTEMD_SERVICE_DIR)/$(TAPCONN_SERVICE)
SYSTEMD_ENV := $(TAPCONN_ROOT)/tapconn.env
DEBUGINFO_REPO := yum.repos.d/debuginfo.repo
KERNEL_VERSION := `uname -a | cut -d ' ' -f 3`
YUM_REPOS_PATH := /etc/yum.repos.d/
YUM_PACKAGES := kernel-debuginfo-$(KERNEL_VERSION) systemtap-runtime kernel-devel-$(KERNEL_VERSION) systemtap

install: yum files reload enable
	@echo 'TapConn service installed, use `make start` or systemctl start $(TAPCONN_SERVICE)'

yum:
	@echo "Installing CentOS debuginfo repository ... "
	@$(SUDO) cp $(DEBUGINFO_REPO) $(YUM_REPOS_PATH) && echo Success || echo Fail
	@$(SUDO) yum update -y || /bin/true
	@echo Installing $(YUM_PACKAGES) ...
	@$(SUDO) yum install -y $(YUM_PACKAGES)
	@echo Installing debuginfo for $(KERNEL_VERSION) ...
	@$(SUDO) debuginfo-install kernel-$(KERNEL_VERSION) --skip-broken

files:
	@echo -n "Copying files ... "
	@$(SUDO) mkdir -p /opt/tapconn
	@$(SUDO) chmod 755 /opt/tapconn
	@$(SUDO) cp systemd/$(TAPCONN_ENV) $(TAPCONN_ROOT)
	@$(SUDO) cp $(TAPCONN_STAP) $(TAPCONN_ROOT)
	@$(SUDO) cp systemd/$(TAPCONN_SERVICE) $(SYSTEMD_SERVICE)
	@$(SUDO) chmod 644 $(SYSTEMD_SERVICE)
	@$(SUDO) chmod 644 $(SYSTEMD_ENV)
	@echo Done

start:
	@echo -n "Starting $(TAPCONN_SERVICE) ... "
	@$(SUDO) systemctl start $(TAPCONN_SERVICE) && echo Success || echo Fail

stop:
	@echo -n "Stopping $(TAPCONN_SERVICE) ... "
	@$(SUDO) systemctl stop $(TAPCONN_SERVICE) && echo Success || echo Fail

restart:
	@echo -n "Restarting $(TAPCONN_SERVICE) ... "
	@$(SUDO) systemctl restart $(TAPCONN_SERVICE) && echo Success || echo Fail

disable:
	@echo -n "Disabling $(TAPCONN_SERVICE) ... "
	@$(SUDO) systemctl disable $(TAPCONN_SERVICE) && echo Success || echo Fail

enable:
	@echo -n "Enabling $(TAPCONN_SERVICE) ... "
	@$(SUDO) systemctl enable $(TAPCONN_SERVICE) && echo Success || echo Fail

reload:
	@echo -n "Reloading systemd services ... "
	@$(SUDO) systemctl daemon-reload && echo Success || echo Fail

clean: stop disable
	@echo -n "Uninstalling $(TAPCONN_SERVICE) completely ... "
	@$(SUDO) rm -rf $(TAPCONN_ROOT) $(SYSTEMD_SERVICE) && echo Success || echo Fail

status:
	@echo "Getting status ... "
	@$(SUDO) systemctl status $(TAPCONN_SERVICE)

.PHONY : clean reload disable start stop files install restart status yum enable
