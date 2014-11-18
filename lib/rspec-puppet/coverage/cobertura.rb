module RSpec::Puppet
  class Coverage

    class << self
      extend Forwardable
      def_delegators :instance, :add, :cobertura!
    end

    def version
      '0.1.0'
    end

    def cobertura!
      summary( coverage )
      File.open( 'coverage.xml' , 'w' ).write( xml )
      report!
    end

    def summary(source_files)
      # Runs over the produced report to extract touched lines

      @modules = Hash.new{|h,k| h[k]=[]}
      source_files.collect{ |e| e[:name].split('/')[0] }.uniq.map{ |e| @modules[e] }

      source_files.each do |source_file|

        touched = {}
        source_file[:coverage].each_with_index { |i,v| touched[v] = i unless i.nil? }

        module_name = source_file[:name].split('/')[0]
        @modules[module_name].push( {
          'filename' => source_file[:name] ,
          'name' => source_file[:name].split('/')[1][0..-4] ,
          'lines' => touched
          } )

      end

    end

    private

      def xml

        output = <<eos
<?xml version="1.0" ?>
<!DOCTYPE coverage SYSTEM 'http://cobertura.sourceforge.net/xml/coverage-04.dtd'>
eos

        unless @modules.values.empty?
          lines = @modules.values.flatten!.collect{ |e| e['lines'].values }.flatten
          rate = lines.select{ |e| not e.zero? }.length.to_f / lines.length

          output += <<eos
<coverage line-rate="#{rate}" timestamp="#{Time.now.to_i}" branch-rate="0" version="#{version}" complexity="0">
  <packages>
eos

          @modules.each do |k,v|
            dump_packages(k,v,'  ').map{ |e| output << '  ' << e << "\n" }
          end

          output += <<eos
  </packages>
</coverage>
eos

        else
          output += '<coverage />'
        end

      end

    def dump_packages( package , classlist , indent='' )
      lines = classlist.collect{ |e| e['lines'].values }.flatten
      rate = lines.select{ |e| not e.zero? }.length.to_f / lines.length

      pkg_fmt = '<package name="%s" line-rate="%s" branch-rate="0">'
      output = [ pkg_fmt % [ package , rate ] ]
      output.push( dump_classes( classlist , '  ' ) ).flatten!
      output.push( '</package>' ).collect{ |e| indent + e.to_s }
    end

    def dump_classes( items , indent='' )
      output = [ '<classes>' ]
      output.push( items.collect{ |e| dump_class( e , '  ' ) } ).flatten!
      output.push( '</classes>' ).collect{ |e| indent + e.to_s }
    end

    def dump_class( item , indent='' )
      rate = item['lines'].select{ |n,h| not h.zero? }.length.to_f / item['lines'].length

      # This block is a bit complex, so adds 'internal indent'
      content = [ '<methods/>' , '<lines>' ]
      content.push( dump_lines( item['lines'] , '  ' ) ).flatten!
      content.push( '</lines>' ).collect!{ |e| '  ' + e.to_s }

      class_fmt = '<class filename="%s" name="%s" line-rate="%s" branch-rate="0">'
      output = [ class_fmt % [ item['filename'] , item['name'] , rate ] ]
      output.push( content ).flatten!
      output.push( '</class>' ).collect{ |e| indent + e.to_s }
    end

    def dump_lines( lines , indent='' )
      lines.collect{ |k,v| indent + '<line number="' + k.to_s + '" hits="' + v.to_s + '" branch="false"/>' }
    end

  end
end
