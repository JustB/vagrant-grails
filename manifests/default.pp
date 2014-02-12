class grails {
  include apt
  apt::ppa { "ppa:webupd8team/java": }
  apt::ppa { "ppa:groovy-dev/grails": }

  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  exec { 'apt-get update 2':
    command => '/usr/bin/apt-get update',
    require => [ Apt::Ppa["ppa:webupd8team/java"], Apt::Ppa["ppa:groovy-dev/grails"], Package["git-core"] ],
  }

  package { ["vim",
             "curl",
             "git-core",
             "bash"]:
    ensure => present,
    require => Exec["apt-get update"],
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  package { ["oracle-java7-installer"]:
    ensure => present,
    require => Exec["apt-get update 2"],
  }

  exec {
    "accept_license":
    command => "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections",
    cwd => "/home/vagrant",
    user => "vagrant",
    path    => "/usr/bin/:/bin/",
    before => Package["oracle-java7-installer"],
    logoutput => true,
  }

  package { ["grails-ppa"]:
    ensure => present,
    require => Package["oracle-java7-installer"],
  }

  exec { "add_java_home":
    command => '/bin/echo "export JAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /home/vagrant/.bashrc',
  }
}

include grails

