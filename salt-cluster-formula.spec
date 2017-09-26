Name:           kvm_cluster_formula
Version:        0.1
Release:        1%{?dist}
Summary:        Salt Cluster Formula for SUSE Manager

License:        GPLv3+
Url:            https://gitlab.com/S-SYS/%{name}
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

# This would be better with a macro that just strips "_formula" from %{name}
%define fname kvm_cluster

%description
Salt Cluster Formula for SUSE Manager. Sets up a complete physical cluster.

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}/usr/share/susemanager/formulas/states/%{fname}
mkdir -p %{buildroot}/usr/share/susemanager/formulas/metadata/%{fname}
cp -R %{fname} %{buildroot}/usr/share/susemanager/formulas/states
cp -R form.yml %{buildroot}/usr/share/susemanager/formulas/metadata/%{fname}
if [ -f metadata.yml ]
then
  cp -R metadata.yml %{buildroot}/usr/share/susemanager/formulas/metadata/%{fname}
fi

%files
%defattr(-,root,root,-)
%license LICENSE
%doc README.md
/usr/share/susemanager/formulas/states/%{fname}
/usr/share/susemanager/formulas/metadata/%{fname}

%changelog
* Wed Sep  22 2017 Cleber Paiva de Souza <cleber@ssys.com.br>
- First version
