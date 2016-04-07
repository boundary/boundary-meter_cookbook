name             'boundary-meter'
maintainer       'Boundary'
maintainer_email 'ops@boundary.com'
license          'Apache 2.0'
description      'Installs/Configures boundary-meter'
long_description 'Installs/Configures boundary-meter'
version          '3.1.9'

%w{ ubuntu debian rhel centos amazon scientific }.each do |os|
  supports os
end

depends 'apt'
depends 'yum', '>= 3.2.0'
