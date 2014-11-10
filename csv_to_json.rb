require 'csv'

loaded = []

CSV.foreach("/Users/zdicklin/Downloads/Batch_1724566_batch_results.csv") do |row|
  name = row[27]
  depth = row[28]
  height = row[29]
  width = row[30]
  filament = row[31]
  price = row[32].to_f
  sd = row[33]
  speed = row[34]
  usb = row[35]
  website = row[36]

  next if loaded.include?(name)
  loaded << name
  
  puts "
    {
      name: '#{name}',
      build_depth: #{depth},
      build_height: #{height},
      build_width: #{width},
      speed: '#{speed}'
      filament: '#{filament}',
      price: #{price},
      sd: #{sd},
      usb: #{usb},
      website: '#{website}',
    },"
end