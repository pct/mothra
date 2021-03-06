#!/usr/bin/env ruby

#require 'awesome_print'
require 'date'
require 'colorize'
require 'thor'
require 'rodzilla'

require 'base64'
require 'pathname'
require 'mkmf'

def clean_bz_url(url)
  if url.end_with? '/'
    url = url[0..-2]
  end

  url
end

def is_numeric?(obj) 
  obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
end

def get_file_name(file_path)
  Pathname.new(file_path).basename
end

def base64(file_path)
  Base64.encode64(IO.read(file_path))
end

def check_config
  config_file = "#{Dir.home}/.mothra.yml"

  if not File.exist?(config_file)
    puts 'You should set ~/.mothra.yml first! Just: '.yellow 
    puts '`curl https://raw.githubusercontent.com/pct/mothra/master/.mothra.yml > ~/.mothra.yml`'.cyan 

    exit
  end
end

check_config

class CLI < Thor
  def initialize(*args)
    super
    @config = YAML.load_file "#{Dir.home}/.mothra.yml"
    @config['BZ_URL'] = clean_bz_url(@config['BZ_URL'])
    @bz = Rodzilla::Resource::Bug.new(@config['BZ_URL'], @config['BZ_USER'], @config['BZ_PASSWD'], :json)
  end

  desc 'search <keyword>, <days_ago=180>', 'search keyword from bugzilla summary for last 180 days or you want'
  def search(keyword, days_ago=180)
    search_days = DateTime.now - days_ago.to_i
    results = @bz.search(product: @config['PRODUCT'], 
                         component: @config['COMPONENT'], 
                         creation_time: search_days, 
                         status: @config['STATUS'], 
                         summary: keyword
                        )

    if not results['bugs'].empty?
      results['bugs'].each_with_index do |r, i|
        print "[#{r['id']}] ".yellow
        print "[#{r['status']}] ".cyan
        print "#{r['summary']} ".white
        puts "[#{r['last_change_time']}] ".light_black
      end
    else
      puts 'Not found.'
    end
  end

  desc 'get <bug_id>', 'get info of <bug_id>'
  def get(bug_id)
    if not is_numeric?bug_id
      puts 'No such bug id'
      exit
    end
    
    ret = @bz.get(ids: bug_id)

    begin
      r = ret['bugs'][0]
      print "[#{r['id']}] ".yellow
      print "[#{r['status']}] ".cyan
      print "#{r['summary']} ".white
      puts "[#{r['last_change_time']}] ".light_black
      puts "#{@config['BZ_URL']}/show_bug.cgi?id=#{bug_id}".cyan
    rescue
      puts 'No such bug_id'
    end
  end

  desc 'browse <bug_id>', 'open <bug_id> at your browser'
  def browse(bug_id)
    if not is_numeric?bug_id
      puts 'No such bug id'
      exit
    end

    url = "#{@config['BZ_URL']}/show_bug.cgi?id=#{bug_id}"

    if RbConfig::CONFIG['host_os'] =~ /darwin/
      system "open #{url}"
    elsif RbConfig::CONFIG['host_os'] =~ /linux|bsd/
      if find_executable 'xdg-open'
        system "xdg-open #{url}"
      else
        puts 'You have no xdg-open command, please browse it manually!'
        puts url.cyan
      end
    else
      puts 'Could not open url at your platform, sorry.'
    end
  end

  desc 'create <summary>', 'set PR summary only, no attachments'
  def create(summary)
    bug_id = _create(summary)

    if not bug_id
      puts 'Send-pr fail, please try again!'.yellow
    else
      print 'PR'
      print " [#{bug_id}] ".yellow
      puts "created!"
      puts "#{@config['BZ_URL']}/show_bug.cgi?id=#{bug_id}".cyan
    end
  end

  desc 'attach <bug_id>, <file_path>', 'add attachment to <bug_id>'
  def attach(bug_id, file_path)
    attach_id = _attach(bug_id, file_path)

    if not attach_id
      puts 'Fail to add attachments, please try again!'.yellow
    else
      print 'PR'
      print " [#{bug_id}] ".cyan
      print 'had add an attachment, '
      puts " [#{attach_id}] ".yellow
      puts "#{@config['BZ_URL']}/show_bug.cgi?id=#{bug_id}".cyan
    end
  end

  desc 'submit <summary>, <file_path>', 'send-pr to bugs.freebsd.org'
  def submit(summary, file_path)
    bug_id = _create(summary)

    if not bug_id
      puts 'Send-pr fail, please try again!'.yellow
      exit
    end

    attach_id = _attach(bug_id, file_path)

    if not attach_id
      puts 'Fail to add attachments, please upload attachment manually!'.yellow
    else
      print 'PR'
      print " [#{bug_id}] ".cyan
      print 'had add an attachment, '
      puts " [#{attach_id}] ".yellow
    end
    puts "#{@config['BZ_URL']}/show_bug.cgi?id=#{bug_id}".cyan
  end

  private

  def _create(summary)
    begin
      ret = @bz.create!(product: @config['PRODUCT'],
                        component: @config['COMPONENT'],
                        #version: '1.0', #bugzilla test 
                        #op_sys: 'FreeBSD', #bugzilla test
                        #platform: 'All', #bugzilla test
                        version: 'Latest',
                        severity: 'Affects Only Me',
                        op_sys: 'Any',
                        platform: 'Any',
                        summary: summary
                       )

      ret['id']
    rescue
      false
    end
  end

  def _attach(bug_id, file_path)
    file_name = get_file_name(file_path)
    file_base64 = base64(file_path)

    begin
      ret = @bz.add_attachment!(ids: [bug_id],
                                data: file_base64,
                                file_name: file_name,
                                summary: file_name,
                                content_type: 'text/plain',
                               )

      ret['ids'][0]
    rescue
      false
    end
  end
  
end

CLI.start(ARGV)
