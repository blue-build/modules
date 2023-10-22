Name:		ublue-os-wallpapers
Vendor:		ublue-os
Version:	{{{ backgrounds_version }}}	
Release:	1%{?dist}
Summary:	Wallpapers for Universal Blue OSes 
License:	Apache-2.0
URL:		https://github.com/%{vendor}/%{name}
BuildArch:	noarch
VCS:           {{{ git_dir_vcs }}}
Source:        {{{ git_dir_pack }}}

%global sub_name %{lua:t=string.gsub(rpm.expand("%{NAME}"), "^ublue%-", ""); print(t)}

%description
Collection of wallpapers for the Universal Blue operating systems

%prep
{{{ git_dir_setup_macro }}}

%install
mkdir -p -m0755 \
    %{buildroot}%{_datadir}/backgrounds/%{VENDOR} \
    %{buildroot}/tmp \
    %{buildroot}%{_datadir}/gnome-background-properties \
    %{buildroot}%{_datadir}/wallpapers/${VENDOR}
tar xzf %{SOURCE0} -C %{buildroot}/tmp --directory . --strip-components=1
mv %{buildroot}/tmp/src/* %{buildroot}%{_datadir}/backgrounds/%{VENDOR}
mv %{buildroot}/tmp/xml/* %{buildroot}%{_datadir}/gnome-background-properties
mv %{buildroot}/tmp/LICENSE %{buildroot}%{_datadir}/backgrounds/%{VENDOR}
cd %{buildroot}%{_datadir}/backgrounds/%{VENDOR}
rm -rf %{buildroot}/tmp

%files
%license LICENSE
%attr(0755,root,root) %{_datadir}/backgrounds/%{VENDOR}/*
%attr(0755,root,root) %{_datadir}/gnome-background-properties/*.xml
%exclude %{_datadir}/background/%{VENDOR}/LICENSE

%post
mkdir -p %{_datadir}/wallpapers/${VENDOR}
ln -sf %{_datadir}/backgrounds/%{VENDOR} %{_datadir}/wallpapers/%{VENDOR}

%changelog
%autochangelog
