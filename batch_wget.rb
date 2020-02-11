#!/usr/bin/env ruby

# replace many wget commands with a single lftp command
require 'uri'

output = []
urls = []

def extract_url(line)
  parts = line.strip.split.reject {|arg| arg =~ /^-/ }
  raise "Bad wget line:#{line}" if parts.size < 2
  parts[1]
end

def wget_generate(urls)
  url_file_path = "temp/urls.txt"

  parsed_uri = URI.parse(urls[0])
  base = "#{parsed_uri.scheme}://#{parsed_uri.host}"
  rel_paths = urls.map {|url| '/' + URI.parse(url).path }
  File.open(url_file_path, 'w') do |out|
    out.puts(rel_paths.join("\n"))
  end

  "wget --mirror --base=#{base} -i #{url_file_path}\n"
end

def lftp_generate(urls)
  parsed_uri = URI.parse(urls[0])
  cmds = []
  cmds << "open #{parsed_uri.host}"
  rel_paths = urls.map {|url| '/' + URI.parse(url).path }
  local_dirs = rel_paths.map {|path| File.join(parsed_uri.host, File.dirname(path))}.uniq
  cmds << "local mkdir -p #{local_dirs.join(" ")}"
  cmds << "set cmd:parallel 5"
  script_file = "temp/lftp_cmds"
  rel_paths.each do |rel_path|
    local_path = File.join(parsed_uri.host, rel_path)
    cmds << "get #{rel_path} -o #{local_path}"
  end

  File.open(script_file, 'w') do |out|
    out.puts(cmds.join("\n"))
  end

  "lftp -f #{script_file}"
end

while line = STDIN.gets
  if line =~ /^\s*wget/
    output << :wget
    urls << extract_url(line)
  else
    output << line
  end
end

STDERR.puts "# urls total #{urls.size}"
urls.uniq!
STDERR.puts "# urls uniq #{urls.size}"

urls.reject! do |url|
  parsed_uri = URI.parse(url)
  file_path = "#{parsed_uri.host}/#{parsed_uri.path}"
  File.exist?(file_path)
end

STDERR.puts "# urls to download #{urls.size}"

wget_cmd = nil

if urls.size > 0
  # wget_cmd = wget_generate(urls)
  wget_cmd = lftp_generate(urls)
end

output.each_with_index do |line, idx|
  if line == :wget
    if wget_cmd
      output[idx] = wget_cmd
      wget_cmd = nil
    else
      output[idx] = "# wget excluded\n"
    end
  end
end

puts output.join()
