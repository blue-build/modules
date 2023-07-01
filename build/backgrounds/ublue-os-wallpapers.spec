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
mkdir -p -m0755 %{buildroot}%{_datadir}/wallpapers/%{VENDOR}
tar xzf %{SOURCE0} -C %{buildroot}%{_datadir}/wallpapers --directory ./%{VENDOR} --strip-components=1
 
%files
%license LICENSE
%attr(0755,root,root) %{_datadir}/wallpapers/%{VENDOR}/*
%exclude %{_datadir}/wallpapers/%{VENDOR}/LICENSE

%changelog
%autochangelog
