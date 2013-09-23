require 'erubis'
require 'find'
require 'json'
require 'pp'

# 翻页js在 http://builtbywill.com/code/booklet/demos/

# usage: script.rb inputdir
def main(path)
	filelist = Find.find(path).select { |f| f =~ /.jpg$/ }

	# slice part of filename as hash key
	# s = 'book_dh79_022_019.jpg'
	# s.split(/(_)/)[0..4].join
	# => "book_dh79_022"
	h = filelist.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |e, o|
		ee = e.sub(path, '') # e without path, only filename
		o[ee[0..12]] << ee
		#o[e.split(/(_)/)[0..4].join] << e
	end
	#p h
	mp3list =  Find.find(path).select { |f| f =~ /.mp3$/ }
	mp3hash = mp3list.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |e, o|
		ee = e.sub(path, '') # e without path, only filename
		# ["book_ys79_050_003.mp3","book_ys79_050_005.mp3"]
		pagenumber, filename = ee.split('.')[0][-3..-1], ee
		o[ee[0..12]] << (pagenumber.to_i - 1) << filename
	end
	h.each do |bookid, pages|
		title = ''
		pages.map! { |e| e.sub(path, '') }.sort! # just in case it's not sorted
		mp3json = Hash[*mp3hash[bookid]].to_json # 因为mp3hash[bookid]是数组，需要splat出来给Hash::[]使用
		#pp mp3json
		eruby = Erubis::Eruby.new(File.read('output/ebook-eruby.html')) # create Eruby object
		index_html =  eruby.result(binding) # get result
		p "output/html/#{bookid}.html"
		File.write("output/html/#{bookid}.html", index_html)
	end

end

if __FILE__ == $PROGRAM_NAME
	input = ARGV[0] || 'output/pageimg/'
	#output = ARGV[1] || 'output/html'
  p "inputdir is #{input}"
  main input
end
