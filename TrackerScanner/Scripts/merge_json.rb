require 'json'

if ARGV[0].to_s.empty?
    $stderr.puts "Usage: #{$PROGRAM_NAME} <results1> [<results2> ...] > output.json"
    exit 1
end

merged_list = []

ARGV.each do |filename|
    json = JSON.parse(File.read(filename))
    merged_list.concat(json)
end

puts JSON.pretty_generate(merged_list)
