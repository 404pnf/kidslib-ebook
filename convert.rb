
# ## 使用方法
#
#   ruby script inputdir, outputdir
#
# ## 目的
# 将图片处理为统一大小。
#
# ---

# ## 使用系统的imagemagick
#
# convert是imagemagick的方法。
# 参考imagemagick文档。
def resize_img(input, out)
  Dir["#{ input }/*.jpg"].each do |f|
    system("convert -scale -strip 600x800 #{ f } #{ out }/#{ f }")
  end
end

# ## 干活
# resize_img 'pageimg-orig', 'pageimg-scaled'