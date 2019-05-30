Name:		azurefirstboot
Version:	0.5
Release:	5
Summary:	runs ansible playbooks after firstboot

Group:		Tools
License:	GPL v3
URL:		http://github.com/linux-system-roles/experimental-azure-firstboot
%global commit f1314a4dc27a78fb06f54e057b8a1b1d6188f4b3
Source0:	https://github.com/linux-system-roles/experimental-azure-firstboot/archive/%{commit}.tar.gz#/%{name}-%{version}.tar.gz
BuildArch:	noarch

Requires:	/bin/bash
Requires:	ansible
%{?systemd_requires}

BuildRequires: systemd

%description
This is a first boot startup service that runs a couple of ansible-playbooks

%prep
%setup -q -n firstboot-%{commit}


%build


%install
rm -rf $RPM_BUILD_ROOT
mkdir -p ${RPM_BUILD_ROOT}/etc/init.d
install -m 755  rootfs/etc/init.d/azfirstboot.sh ${RPM_BUILD_ROOT}/etc/init.d/azfirstboot.sh
chcon -u system_u -t initrc_exec_t ${RPM_BUILD_ROOT}/etc/init.d/azfirstboot.sh
mkdir -p ${RPM_BUILD_ROOT}/etc/systemd/system
install -m 644  rootfs/etc/systemd/system/azfirstboot.service ${RPM_BUILD_ROOT}/etc/systemd/system/azfirstboot.service
chcon -u system_u -t systemd_unit_file_t ${RPM_BUILD_ROOT}/etc/systemd/system/azfirstboot.service
#mkdir -p ${RPM_BUILD_ROOT}/etc/azfirstboot.d

%preun
%systemd_preun azfirstboot.service

%post
if [ $1 -eq 1 ]; then
	# Package install,
	/bin/systemctl enable azfirstboot.service >/dev/null 2>&1 || :
else
	# Package upgrade
	if /bin/systemctl --quiet is-enabled azfirstboot.service ; then
		/bin/systemctl reenable azfirstboot.service >/dev/null 2>&1 || :
	fi
fi

%postun
%systemd_postun azfirstboot.service

%files
%defattr(-,root,root,-)
/etc/init.d/azfirstboot.sh
/etc/systemd/system/azfirstboot.service

%license LICENSE



%changelog
* Thu May 30 2019 Pavel Cahyna <pcahyna@redhat.com> - 0.5-5
- fix upstream URL after the transfer of the GitHub repo

* Fri Jan 18 2019 Markus Koch |mkoch@redhat.com> - 0.4
- bugfixes
* Fri Dec 21 2018 Markus Koch |mkoch@redhat.com> - 0.1
- initial build

