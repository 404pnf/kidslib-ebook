require 'pp'
require 'fileutils'
f = Dir['*.jpg']
ff = f.select { |e| e =~ /_[0-9]\.jpg/ }
      .map { |e| [e, e.sub(/_[0-9]\.jpg/, '.jpg')] }
pp ff
#g = f.select { |e| e =~ /'/ or e =~ / / }
#      .map { |e| [e, e.gsub(/[' ]/, '_')] }
#pp g

#ff.each { |(old, new)| FileUtils.mv(old, new, :verbose => true, :noop => true) }
ff.each { |(old, new)| FileUtils.mv(old, new, :verbose => true) }
#g.each { |(old, new)| FileUtils.mv(old, new, :verbose => true) }
