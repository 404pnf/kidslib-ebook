
Dir['pageimg-orig/*.jpg'].each do |f|
  system("convert -scale -strip 600x800 #{f} pageimg-scaled/#{f}")
end
