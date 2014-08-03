module RSpec::Puppet
  class Coverage

    class << self
      extend Forwardable
      def_delegators :instance, :add, :cobertura!
    end

    def cobertura!
      File.open( 'coverage.xml' , 'w' ).write( xml )
      report!
    end

    private

      def xml
        <<eos
<?xml version="1.0" ?>
<!DOCTYPE coverage SYSTEM 'http://cobertura.sourceforge.net/xml/coverage-04.dtd'>
<coverage />
eos
      end

  end
end
