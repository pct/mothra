# Mothra

A FreeBSD send-pr command line tool for bugzilla system.

[https://bugs.freebsd.org/bugzilla/](https://bugs.freebsd.org/bugzilla/)

## Installation

	$ gem install mothra
    
## Add ~/.mothra.yml settings 
	$ curl https://raw.githubusercontent.com/pct/mothra/master/.mothra.yml > ~/.mothra.yml

or create manually:

	# bugzilla base data
	BZ_URL: https://bugs.freebsd.org/bugzilla/
	BZ_USER: test@example.com
	BZ_PASSWD: test
	
	PRODUCT: Ports & Packages
	COMPONENT: Individual Port(s)
	STATUS: ['New', 'Open', 'In Progress', 'UNCONFIRMED']

## Usage
	Commands:
	  mothra attach <bug_id>, <file_path>      # add attachment to <bug_id>
	  mothra create <summary>                  # set PR summary only, no attachments
	  mothra help [COMMAND]                    # Describe available commands or one specific command
	  mothra search <keyword>, <days_ago=180>  # search keyword from bugzilla summary for last 180 days or you want
	  mothra submit <summary>, <file_path>     # send-pr to bugs.freebsd.org

## Reference
1. [https://bugs.freebsd.org/bugzilla/](https://bugs.freebsd.org/bugzilla/)
2. [http://www.bugzilla.org/docs/4.4/en/html/api/Bugzilla/WebService/Server/JSONRPC.html](http://www.bugzilla.org/docs/4.4/en/html/api/Bugzilla/WebService/Server/JSONRPC.html)

## License

	Copyright (c) 2015 Jin-Sih Lin
	
	MIT License
	
	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:
	
	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
## Contributing

1. Fork it ( https://github.com/pct/mothra/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## TODO

`mothra get <bug_id>`

`mothra comment <bug_id>`
