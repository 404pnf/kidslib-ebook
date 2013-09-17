require 'erubis'
require 'find'


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

	h.each do |bookid, pages|
		title = ''
		pages.map! { |e| e.sub(path, '') }.sort! # just in case it's not sorted
  	eruby = Erubis::Eruby.new(File.read('ebook-eruby.html')) # create Eruby object
  	index_html =  eruby.result(binding) # get result
  	p "output-ebook/html/#{bookid}.html"
  	File.write("output-ebook/html/#{bookid}.html", index_html)
	end

end

if __FILE__ == $PROGRAM_NAME
	input = ARGV[0] || 'output-ebook/pageimg/'
	#output = ARGV[1] || 'output-ebook/html'
  p "inputdir is #{input}"
  main input
end
