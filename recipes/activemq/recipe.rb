class ActiveMQ < FPM::Cookery::Recipe
  name 'apache-activemq'
  version '5.15.6'
  url 'http://archive.apache.org/dist/activemq/5.15.6/apache-activemq-5.15.6-bin.tar.gz'
  # Checksum from http://archive.apache.org/dist/activemq/5.15.6/apache-activemq-5.15.6-bin.tar.gz.sha512
  sha512 'a1b931a25c513f83f4f712cc126ee67a2b196ea23a243aa6cafe357ea03f721fba6cb566701e5c0e1f2f7ad8954807361364635c45d5069ec2dbf0ba5c6b588b'

  def build
  end

  def install
    opt.install Dir["#{builddir}/*"]
  end

end
