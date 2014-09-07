require 'formula'
require 'cmd/config'
require 'net/http'
require 'net/https'
require 'stringio'

def gist_logs f
  if ARGV.include? '--new-issue'
    unless HOMEBREW_GITHUB_API_TOKEN
      puts 'You need to create an API token: https://github.com/settings/applications'
      puts 'and then set HOMEBREW_GITHUB_API_TOKEN to use --new-issue option.'
      exit 1
    end
  end

  files = load_logs(f.name)

  s = StringIO.new
  Homebrew.dump_verbose_config(s)
  files["config.out"] = { :content => s.string }
  files["doctor.out"] = { :content => `brew doctor 2>&1` }

  url = create_gist(files)

  if ARGV.include? '--new-issue'
    url = new_issue(f.tap, "#{f.name} failed to build on #{MACOS_FULL_VERSION}", url)
  end

  ensure puts url if url
end

def load_logs name
  logs = {}
  dir = HOMEBREW_LOGS/name
  dir.children.sort.each do |file|
    contents = file.size? ? file.read : "empty log"
    logs[file.basename.to_s] = { :content => contents }
  end if dir.exist?
  raise 'No logs.' if logs.empty?
  logs
end

def create_gist files
  post("/gists", "public" => true, "files" => files)["html_url"]
end

def new_issue repo, title, body
  post("/repos/#{repo}/issues", "title" => title, "body" => body)["html_url"]
end

def http
  @http ||= begin
    uri = URI.parse('https://api.github.com')
    p = ENV['http_proxy'] ? URI.parse(ENV['http_proxy']) : nil
    if p.class == URI::HTTP or p.class == URI::HTTPS
      @http = Net::HTTP.new(uri.host, uri.port, p.host, p.port, p.user, p.password)
    else
      @http = Net::HTTP.new(uri.host, uri.port)
    end
    @http.use_ssl = true
    @http
  end
end

def post path, data
  request = Net::HTTP::Post.new(path)
  request['User-Agent'] = HOMEBREW_USER_AGENT
  request['Content-Type'] = 'application/json'
  if HOMEBREW_GITHUB_API_TOKEN
    request['Authorization'] = "token #{HOMEBREW_GITHUB_API_TOKEN}"
  end
  request.body = Utils::JSON.dump(data)
  response = http.request(request)
  raise "HTTP #{response.code} #{response.message}" if response.code != "201"

  if !response.body.respond_to?(:force_encoding)
    body = response.body
  elsif response["Content-Type"].downcase == "application/json; charset=utf-8"
    body = response.body.dup.force_encoding(Encoding::UTF_8)
  else
    body = response.body.encode(Encoding::UTF_8, :undef => :replace)
  end

  Utils::JSON.load(body)
end

if ARGV.formulae.length != 1
  puts "usage: brew gist-logs [--new-issue] <formula>"
  exit 1
end

gist_logs(ARGV.formulae[0])
