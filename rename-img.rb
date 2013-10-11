# ## 目的
# 之前导入这些文件进入drupal的时候，因为导入了多次。
# 有些文件名有了给重复文件重命名的数字后缀。
# 比如 file.jpg 导入多次会变为 file_1.jpg, file_2.jpg 。
#
# 现在我要去掉这些数字后缀。因为我的脚本不会产生druapl中重复导入出现的问题。
# 因此我需要将这些文件重命名为其原始状态。
#
# 这个脚本只用一次，日后很可能也不会再用了。因为日后本项目应该不会遇到相同问题。
#
# ----

require 'pp'
require 'fileutils'

def rename_img(input)
  f = Dir["#{ input }/*.jpg"]
  ff = f.select { |e| e =~ /_[0-9]\.jpg/ }
        .map { |e| [e, e.sub(/_[0-9]\.jpg/, '.jpg')] }
  pp ff

  # 有些文件名中还有英文单引号！
  #g = f.select { |e| e =~ /'/ or e =~ / / }
  #      .map { |e| [e, e.gsub(/[' ]/, '_')] }
  #pp g

  # ** 先noop: true ** 看看效果
  ff.each { |(old, new)| FileUtils.mv(old, new, :verbose => true, :noop => true) }
  #ff.each { |(old, new)| FileUtils.mv(old, new, :verbose => true) }
  #g.each { |(old, new)| FileUtils.mv(old, new, :verbose => true) }
end

# rename_img(input)
