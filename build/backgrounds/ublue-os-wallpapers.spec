Name:		ublue-os-wallpapers
Vendor:		ublue-os
Version:	0.1
Release:	1%{?dist}
Summary:	Wallpapers for Ublue OS
License:	Apache-2.0
URL:		https://github.com/ublue-os/bling
BuildArch:	noarch
Source0:	%{NAME}.tar.gz 

%description
Collection of wallpapers for the Universal Blue operating systems

%prep
%setup -q -c

%build

%install
mkdir -p -m0755 \
    %{buildroot}%{_datadir}/backgrounds/%{VENDOR} \
    %{buildroot}/tmp \
    %{buildroot}%{_datadir}/gnome-background-properties \
    %{buildroot}%{_datadir}/wallpapers/${VENDOR}
tar xzf %{SOURCE0} -C %{buildroot}/tmp --directory . --strip-components=1
mv %{buildroot}/tmp/src/* %{buildroot}%{_datadir}/backgrounds/%{VENDOR}
mv %{buildroot}/tmp/xml/* %{buildroot}%{_datadir}/gnome-background-properties
mv %{buildroot}/tmp/LICENSE_APACHE %{buildroot}%{_datadir}/backgrounds/%{VENDOR}
cd %{buildroot}%{_datadir}/backgrounds/%{VENDOR}
rm -rf %{buildroot}/tmp

%files
%license LICENSE_CCBYSA
%attr(0755,root,root) %{_datadir}/backgrounds/%{VENDOR}/*
%attr(0755,root,root) %{_datadir}/gnome-background-properties/*.xml
%exclude %{_datadir}/background/%{VENDOR}/LICENSE_CCBYSA

%post
mkdir -p %{_datadir}/wallpapers/${VENDOR}
ln -sf %{_datadir}/backgrounds/%{VENDOR} %{_datadir}/wallpapers/%{VENDOR}

%changelog
%autochangelog
