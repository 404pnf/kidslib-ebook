# ## 使用方法
#
#     ruby script.rb inpudir


# ----
# ## 目的
# 将输入目录的图片按书名编号手机起来，在output文件夹生成对应的图书。
#
# 1. 每本图书有标题
# 1. 每本图书有翻页效果。
# 1. 有些页面有匹配音频。
# 1. 显示逻辑在 views/ 模版中
# 1. 翻页js由xb完成，音频js由tian完成。
# 1. 翻页js在 <http://builtbywill.com/code/booklet/demos/>
#

# ----
# ## 库

require 'erubis'
require 'find'
require 'json'
require 'pp'
require 'fileutils'
require 'csv'

# ----
# ## 主函数
# 1. 选取输入目录的所有jpg文件
# 1. 读入titles.csv 格式为 nid, id, title 其中id是书的编号，title就是题目。nid是之前drupal中用到的
# 1. 每个jpg或mp3文件的文件名中都包含该书的唯一id，这个id是和titles.csv中id对应的
# 1. 文件名中的唯一id不能简单粗暴地用字符串长度来获得，因为不同书的id长度也不同！


# ----
# ## 如何从jpg文件名中获得图书id
#
# ### 错误
# 因为不一定所有文件名都是前3个作为id。要是有2个或者4个的呢？
#
#     s = 'book_dh79_022_019.jpg'
#     s.split(/(_)/)[0..4].join
#     => "book_dh79_022"
#

# ----
# ### 正确
# 把文件名分割后，最后一部分是页码，之前的嗾使book id。
#
#      h = filelist.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |e, o|
#      ee = File.basename(e) # 只保留文件名
#      # 文件名 book_th13_008_021.jpg    hb_cz46_030_019.jpg
#      *bid, _ = ee.split(/_/) # 最后一个item是页码编号，不属于图书id，之前的都属于id
#      bookid = bid.join('_').to_sym # 再用 '_' 连成字符串
#

# ----
# ## 获得图书标题
# 从csv文件中获得标题。
# 返回结果为hash。每条记录内容类似：
#
#       "book_dh79_022"=>"舒克和贝塔-大战海盗", "book_dh79_023"=>"舒克和贝塔-克里斯王国", "book_dh79_024"=>"舒克和贝塔-人鼠之战"
#
def get_title(path)
  CSV.table(path).each_with_object({}) do |e, o|
    id, title = e[:id].to_sym, e[:title]
    o[id] = title
  end
end

# ----
# ## 从jpg文件列表中构建图书hash
def get_jpg(path)
  filelist = Find.find(path).select { |f| f =~ /.jpg$/ }
  h = filelist.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |e, o|
    ee = File.basename(e) # e without path, only filename
    *bid, _ = ee.split(/_/) # 最后一个item是页码编号，不属于图书id
    bookid = bid.join('_').to_sym

    o[bookid] << ee
  end
  p "共有图书 #{ h.size } 本"
  h
end

# ----
# ## 获取mp3信息
# 1. 从mp3文件名中获取图书id。方法同jpg文件
# 1. mp3对应的页面书需要减1。因为显示阶段的页面是从0开始。而编辑加工的时候是从1开始。
# 1. 输出为hash，内容类似
#
#        :book_ys79_052=>[2, "book_ys79_052_003.mp3", 4, "book_ys79_052_005.mp3"],
#
def get_mp3(path)
  mp3list =  Find.find(path).select { |f| f =~ /.mp3$/ }
  mp3list.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |e, o|
    ee = File.basename(e) # ["book_ys79_050_003.mp3","book_ys79_050_005.mp3"]
    pagenumber, filename = ee[-7..-5], ee
    *bid, _ = ee.split(/_/)
    bookid = bid.join('_').to_sym

    o[bookid] << (pagenumber.to_i - 1) << filename
  end
end

# ----
# ## 合并jpg图片的hash，mp3的hash和图书标题的hash 并将结果写到单个文件
# 1. 合并3个hash为一个大hash，键是书的id
# 1. 绑定每本书的变量的模版文件
# 1. 写文件
#
def merge_and_write(jpg_h, mp3_h, titles_h, out)
  jpg_h.each do |bookid, pages|
    title = titles_h[bookid]
    pages.sort!
    mp3json = Hash[*mp3_h[bookid]].to_json # 因为mp3hash[bookid]是数组，需要splat出来给Hash::[]使用

    eruby = Erubis::Eruby.new(File.read('views/ebook-eruby.html')) # create Eruby object
    index_html =  eruby.result(binding) # get result

    p "#{out}/#{bookid}.html"
    File.write("#{out}/#{bookid}.html", index_html)
  end
end

# ----
# ## 复制静态文件
def copy_asset_to_output(out)
  FileUtils.cp_r 'views/.', out, :verbose => true
end

# ----
# ## 干活
if __FILE__ == $PROGRAM_NAME
  input = ARGV[0] || '_output/pageimg/'
  output = ARGV[1] || '_new_output/html'
  TITLES_CSV = './titles.csv'
  p "inputdir is #{ input }"
  p "outputdir is #{ output }"

  jpg, titles, mp3 = get_jpg(input), get_title(TITLES_CSV), get_mp3(input)
  merge_and_write jpg, mp3, titles, output # 注意要严格按照顺序传入

  copy_asset_to_output output
end
